import { consola } from 'consola'

export function info (prefix: string, message: any, options: any = null) {
  consola.info({
    message: `[${prefix}] ${message}`,
    additional: options ? JSON.stringify(options, null, 2) : null
  })
}

export function warn (prefix: string, message: any, options: any = null) {
  consola.warn({
    message: `[${prefix}] ${message}`,
    additional: options ? JSON.stringify(options, null, 2) : null
  })
}

export function fatal (prefix: string, message: any, options: any = null) {
  consola.fatal({
    message: `[${prefix}] ${message}`,
    additional: options ? JSON.stringify(options, null, 2) : null
  })
}

export function success (prefix: string, message: any, options: any = null) {
  consola.success({
    message: `[${prefix}] ${message}`,
    additional: options ? JSON.stringify(options, null, 2) : null
  })
}
