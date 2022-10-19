export default class AppCtrl {
  constructor() {
    self.currentFilters = {}
  }

  toggleSidebar() {
    toggleClass('#sidebar', 'hidden')
    toggleClass('#open', 'hidden')
    toggleClass('#close', 'hidden')
  }

  filterBy(type, attribute = 'all', options = {}) {
    addClass('.card', 'hidden')

    const el = currentElement()
    const currentValue = el.value

    self.currentFilters[el.name || attribute] = { type, currentValue, options }

    window.collection.forEach((item) => {
      let show = true

      Object.values(self.currentFilters).forEach((filter) => {
        show = show && applyFilter(item, attribute, filter)
      })

      if (show) showItem(item)
    })

    insertHTML('#counter', findAll('article:not(.hidden)').length)
  }

  applyFilter(item, attribute, filter) {
    const itemValue = item[attribute]

    switch(filter.type) {
      case 'global_text':
        const attrs = Object.values(item).filter(isString)

        if (attrs.join(' ').match(filter.currentValue))
          return true

        break;
      case 'text':
        if (filter.currentValue.match(itemValue))
          return true

        break;
      case 'select':
        if (filter.currentValue == itemValue)
          return true

        break;
      case 'numeric_range':
        const currentValue = parseInt(filter.currentValue)

        if (filter.options['range'] == 'min' && itemValue > currentValue)
          return true

        if (filter.options['range'] == 'max' && itemValue <= currentValue)
          return true

        break;
      case 'tags':
        if (itemValue && itemValue.includes(filter.options['tag']))
          return true

        break;
      case 'boolean':
        if (filter.currentValue == 'true' && itemValue)
          return true

        if (filter.currentValue == 'false' && !itemValue)
          return true

        break;
      default:
        return false
    }
  }

  showItem(item) {
    removeClass(`#${item.dom_id}`, 'hidden')
  }

  isString(string) {
    if (typeof string === 'string' || string instanceof String)
      return true
  }
}
