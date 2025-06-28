#!/bin/bash
# Creative Pack Aliases - Add to ~/.zshrc

# Weather
alias weather='~/Terminal_Power/scripts/weather-tools.sh'
alias forecast='~/Terminal_Power/scripts/weather-tools.sh forecast'

# Colors  
alias colorscheme='~/Terminal_Power/scripts/color-tools.sh scheme'
alias colorname='~/Terminal_Power/scripts/color-tools.sh name'
alias palette='~/Terminal_Power/scripts/color-tools.sh palette'
alias randomcolor='~/Terminal_Power/scripts/color-tools.sh random'

# Quick utilities (using existing tools)
alias qr='curl -s "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data='
alias qr-download='curl -s "https://api.qrserver.com/v1/create-qr-code/?size=400x400&data='

# Fake data
alias fake-people='curl -s "https://fakerapi.it/api/v1/persons?_quantity='
alias fake-companies='curl -s "https://fakerapi.it/api/v1/companies?_quantity='

# Quotes
alias quote='curl -s "https://api.quotable.io/random" | jq -r ".content + \" - \" + .author"'
alias quote-design='curl -s "https://api.quotable.io/random?tags=design" | jq -r ".content + \" - \" + .author"'

# URL shortening  
alias shorten='curl -s "https://is.gd/create.php?format=simple&url='

# Placeholder images
alias placeholder='curl -s "https://picsum.photos/'