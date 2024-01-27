package fr.skyost.bonsoir.discovery

import android.util.Log
import fr.skyost.bonsoir.BonsoirService
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.DataInputStream
import java.io.DataOutputStream
import java.io.EOFException
import java.io.IOException
import java.io.OutputStream
import java.net.DatagramPacket
import java.net.InetAddress
import java.net.MulticastSocket
import java.net.SocketTimeoutException


/**
 * Allows to resolve a service TXT record.
 * Chery pick of https://github.com/youviewtv/tinydnssd/blob/master/lib/src/main/java/com/youview/tinydnssd/MDNSDiscover.java.
 */
class TxtRecord {
    companion object {
        /**
         * The multicast group address.
         */
        private const val MULTICAST_GROUP_ADDRESS = "224.0.0.251"

        /**
         * The TXT record.
         */
        private const val QTYPE_TXT = 0x0010

        /**
         * Internet class.
         */
        private const val QCLASS_INTERNET = 0x0001

        /**
         * Unicast cast.
         */
        private const val CLASS_FLAG_UNICAST = 0x8000

        /**
         * The query port.
         */
        private const val PORT = 5353

        /**
         * Ask for the TXT record of a particular service.
         *
         * @param timeout Duration in milliseconds to wait for an answer packet. If `0`, this method will listen forever.
         *
         * @return Whether record has been resolved successfully.
         */
        suspend fun resolveTxtRecord(service: BonsoirService, port: Int? = null, timeout: Int = 2000): TxtRecordData? {
            try {
                val group = InetAddress.getByName(MULTICAST_GROUP_ADDRESS)
                val sock = if (port == null) MulticastSocket() else MulticastSocket(port)
                sock.reuseAddress = true
                sock.joinGroup(group)
                val data = queryPacket(service, QCLASS_INTERNET or CLASS_FLAG_UNICAST, QTYPE_TXT)
                var packet = DatagramPacket(data, data.size, group, PORT)
                sock.timeToLive = 255
                sock.send(packet)
                val buf = ByteArray(1024)
                packet = DatagramPacket(buf, buf.size)
                var txtRecord: TxtRecordData? = null
                var endTime: Long = 0
                if (timeout != 0) {
                    endTime = System.currentTimeMillis() + timeout
                }
                // records could be returned in different packets, so we have to loop
                // timeout applies to the acquisition of ALL packets
                while (txtRecord == null) {
                    if (timeout != 0) {
                        val remaining = (endTime - System.currentTimeMillis()).toInt()
                        if (remaining <= 0) {
                            break
                        }
                        sock.soTimeout = remaining
                    }
                    sock.receive(packet)
                    txtRecord = decodeTxtRecordIfPossible(packet.data, packet.length)
                }
                return txtRecord
            } catch (ex: SocketTimeoutException) {
                if (port == null) {
                    Log.d("TXTRecord", "Unable to query for a TXT record. Will now retry with a different port...")
                    return resolveTxtRecord(service, PORT)
                }
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
            return null
        }

        @Throws(IOException::class)
        private fun queryPacket(service: BonsoirService, qclass: Int, vararg qtypes: Int): ByteArray {
            val bos = ByteArrayOutputStream()
            val dos = DataOutputStream(bos)
            dos.writeInt(0)
            dos.writeShort(qtypes.size) // questions
            dos.writeShort(0) // answers
            dos.writeShort(0) // nscount
            dos.writeShort(0) // arcount
            var fqdnPtr = -1
            for (qtype in qtypes) {
                if (fqdnPtr == -1) {
                    fqdnPtr = dos.size()
                    writeFqdn(service, dos)
                } else {
                    // packet compression, string is just a pointer to previous occurrence
                    dos.write(0xc0 or (fqdnPtr shr 8))
                    dos.write(fqdnPtr and 0xFF)
                }
                dos.writeShort(qtype)
                dos.writeShort(qclass)
            }
            dos.close()
            return bos.toByteArray()
        }

        @Throws(IOException::class)
        private fun writeFqdn(service: BonsoirService, out: OutputStream) {
            for (part in listOf(service.name, service.type, "local")) {
                out.write(part.length)
                out.write(part.toByteArray())
            }
            out.write(0)
        }

        @Throws(IOException::class)
        private fun decodeTxtRecordIfPossible(packet: ByteArray, packetLength: Int): TxtRecordData? {
            val dis = DataInputStream(ByteArrayInputStream(packet, 0, packetLength))
            val transactionID = dis.readShort()
            val flags = dis.readShort()
            val questions = dis.readUnsignedShort()
            val answers = dis.readUnsignedShort()
            val authorityRRs = dis.readUnsignedShort()
            val additionalRRs = dis.readUnsignedShort()
            // decode the queries
            for (i in 0 until questions) {
                val fqdn: String = decodeFqdn(dis, packet, packetLength)
                val type = dis.readShort()
                val qclass = dis.readShort()
            }
            // decode the answers
            for (i in 0 until answers + authorityRRs + additionalRRs) {
                val fqdn: String = decodeFqdn(dis, packet, packetLength)
                val type = dis.readShort()
                val aclass = dis.readShort()
                val ttl = dis.readInt()
                val length = dis.readUnsignedShort()
                val data = ByteArray(length)
                dis.readFully(data)
                if (type.toInt() == QTYPE_TXT) {
                    val txtRecord = decodeTxt(data)
                    txtRecord.fqdn = fqdn
                    txtRecord.ttl = ttl
                    return txtRecord
                }
            }
            return null
        }

        @Throws(IOException::class)
        private fun decodeTxt(data: ByteArray): TxtRecordData {
            val txtRecord = TxtRecordData()
            val dis = DataInputStream(ByteArrayInputStream(data))
            while (true) {
                val length: Int = try {
                    dis.readUnsignedByte()
                } catch (e: EOFException) {
                    return txtRecord
                }
                val segmentBytes = ByteArray(length)
                dis.readFully(segmentBytes)
                val segment = String(segmentBytes)
                val pos = segment.indexOf('=')
                var key: String
                var value: String? = null
                if (pos != -1) {
                    key = segment.substring(0, pos)
                    value = segment.substring(pos + 1)
                } else {
                    key = segment
                }
                if (!txtRecord.dictionary.containsKey(key)) {
                    // from RFC6763
                    // If a client receives a TXT record containing the same key more than once, then
                    // the client MUST silently ignore all but the first occurrence of that attribute."
                    txtRecord.dictionary[key] = value ?: "null"
                }
            }
        }

        @Throws(IOException::class)
        private fun decodeFqdn(dis: DataInputStream, packet: ByteArray, packetLength: Int): String {
            var dataInputStream = dis
            val result = StringBuilder()
            var dot = false
            while (true) {
                var pointerHopCount = 0
                var length: Int
                while (true) {
                    length = dataInputStream.readUnsignedByte()
                    if (length == 0) {
                        return result.toString()
                    }
                    if (length and 0xc0 == 0xc0) {
                        // this is a compression method, the remainder of the string is a pointer to elsewhere in the packet
                        // adjust the stream boundary and repeat processing
                        if (++pointerHopCount * 2 >= packetLength) {
                            // We must have visited one of the possible pointers more than once => cycle
                            // this doesn't add to the domain length, but decoding would be non-terminating
                            throw IOException("cyclic empty references in domain name")
                        }
                        length = length and 0x3f
                        val offset = length shl 8 or dataInputStream.readUnsignedByte()
                        dataInputStream =
                            DataInputStream(ByteArrayInputStream(packet, offset, packetLength - offset))
                    } else {
                        break
                    }
                }
                val segment = ByteArray(length)
                dataInputStream.readFully(segment)
                if (dot) {
                    result.append('.')
                }
                dot = true
                result.append(String(segment))
                if (result.length > packetLength) {
                    // If we get here, we must be following cyclic references, since non-cyclic
                    // references can't encode a domain name longer than the total length of the packet.
                    // The domain name would be infinitely long, so abort now rather than consume
                    // maximum heap.
                    throw IOException("cyclic non-empty references in domain name")
                }
            }
        }
    }
}

/**
 * Represents the decoded content of the answer sections of an incoming packet.
 * When the corresponding data is present in an answer, fields will be initialized with
 * populated data structures. When no such answer is present in the packet, fields will be
 * `null`.
 */
data class TxtRecordData(
    /**
     * The service FQDN.
     */
    var fqdn: String? = null,
    /**
     * The record TTL.
     */
    var ttl: Int? = null,
    /**
     * The content of the TXT record's key-value store decoded as a [Map].
     */
    val dictionary: HashMap<String, String> = HashMap()
)
