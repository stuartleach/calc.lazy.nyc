# Calculator Project

This is a simple calculator project that allows users to perform basic arithmetic operations such as addition, subtraction, multiplication, and division.

## Technologies

This calculator uses Turbo on Rails, serving html templates on demand without needing an entire page load.

## Philosophy

Because I wanted to grok Ruby, Rails, and Turbo quickly, I sacrificed speed for the sake of becoming more familiar with Turbo and Rails.

If I were to optimize this app for speed, I would use inline JS to replace `@display` with each numpad input, and only serve a new turbo-frame when a calculation is required, and potentially log that to a SQLite DB.

Other considerations: I thought about saving the state of an operation to the browser's history, but decided against it.

## Installation

Clone the repository:

```bash
git clone https://github.com/stuartleach/calc.lazy.nyc.git
```
