# mock-generate
 
## Description
Generate mock data with fields:
- Full name
- Address
- Phone number

Output example:

`Arno Haley | United States, Idaho, Avenue Sonsing, 143-E | 810175868483`

## Usage
`node get-mock.js arg1 arg2 arg3`
- arg1 - count of lines
- arg2 - locale ('en', 'ru', 'by' are avail)
- arg3 - count of mistakes in each line

At line 5 of script set **consoleOutput** = **_false_** if you don't want to see the result =)