import { loadIcon } from '@iconify/vue'

export const useShikiCopy = () => {
  onMounted(addCopyButtons)
}

const addCopyButtons = async () => {
  const shikiContainers = document.querySelectorAll('.shiki-container')
  for (const container of shikiContainers) {
    const copyIcon = await loadIcon('bi:copy')
    const copyIconSvg = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
    copyIconSvg.setAttribute('class', 'copy-icon')
    copyIconSvg.setAttribute('title', 'Copy to clipboard')
    copyIconSvg.setAttribute('height', copyIcon.height.toString())
    copyIconSvg.setAttribute('width', copyIcon.width.toString())
    copyIconSvg.setAttribute('aria-hidden', 'true')
    copyIconSvg.innerHTML = copyIcon.body
    copyIconSvg.addEventListener('click', () => {
      const codeContent = container.querySelector('code')?.textContent || ''
      navigator.clipboard.writeText(codeContent)
    })
    container.appendChild(copyIconSvg)
  }
}
