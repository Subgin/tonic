export function contains(content, search) {
  const regexp = new RegExp(search, 'i')

  return regexp.test(content)
}

export function stripTags(string) {
  const parseHTML = new DOMParser().parseFromString(string, 'text/html')

  return parseHTML.body.textContent || ''
}

export function deepValues(obj, values = []) {
  Object.values(obj).forEach(val => {
    if (val instanceof Object)
      deepValues(val, values)
    else
      values.push(val)
  })

  return values.join(' ')
}

export function sortArray(array, attribute, direction) {
  return array.sort((a, b) => {
    if (direction == 'asc') {
      if (a[attribute] < b[attribute]) return -1
      if (a[attribute] > b[attribute]) return 1
      return 0
    } else {
      if (a[attribute] < b[attribute]) return 1
      if (a[attribute] > b[attribute]) return -1
      return 0
    }
  })
}
