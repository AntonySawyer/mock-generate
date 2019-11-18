const fs = require('fs');

console.time('Generate time');
const consoleOutput = false;

const count = process.argv[2];
const locale = process.argv[3];
const typoCount = process.argv[4];

const result = [];
let delState = 1; // To keep balace. +1: delete char, -1: paste char

const {
  address,
  name,
  additional
} = JSON.parse(fs.readFileSync(`./lib/locales/${locale}.json`, 'utf8'));

for (let i = 0; i < count; i++) {
  const mock = [getName(name), getAddress(address), getPhoneNumber(additional.phonenumber)];
  if (typoCount != 0) {
    for (let i = 0; i < typoCount; i++) {
      const mockPart = getRandom(mock.length);
      mock[mockPart] = getTypo(mock[mockPart]);
    }
  }
  result.push(mock.join('| '));
}
consoleOutput ? result.forEach(el => console.log(el)) : fs.appendFileSync('./output.csv', result.join('\n'), err => console.error(err));

function getTypo(str) {
  const missingIndex = getRandom(str.length - 3, 1);
  switch (getRandom(2)) {
    case 0: // delete or paste char
      delState *= -1;
      return `${str.slice(0, missingIndex)}${str.slice(missingIndex + delState)}`;
    case 1: // change order
      return `${str.slice(0, missingIndex)}${str[missingIndex+1]}${str[missingIndex]}${str.slice(missingIndex+2)}`;
    default:
      break;
  }
}

function getName(obj) {
  const keys = Object.keys(obj);
  const gender = keys[getRandom(keys.length)];
  const randomName = [];
  for (const field in obj[gender]) {
    const target = obj[gender][field];
    const name = target[getRandom(target.length)]
    randomName.push(name);
  }
  return randomName.join(' ');
}

function getAddress(obj) {
  const randomAddress = [];
  for (const field in obj) {
    const target = obj[field];
    const name = target[getRandom(target.length)];
    randomAddress.push(`${name}${field === 'prefix' ? ' ' : ', '}`);
  }
  randomAddress.push(getRandom(200), getPostfix());
  return randomAddress.join('');
}

function getPostfix() {
  const chars = ['-', '/', ' '];
  if (getRandom(2)) {
    return `${chars[getRandom(2)]}${getRandom(2) ? additional.postfix[getRandom(5)] : getRandom(5, 1)}`;
  }
}

function getPhoneNumber(pattern) {
  return pattern.split('').map((el, i, arr) => el === '#' ? arr[i] = getRandom(9) : el).join('');
}

function getRandom(max, min = 0) {
  return Math.floor(Math.random() * max) + min;
}

console.timeEnd('Generate time');