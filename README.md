# Retrieve rules of origin from a Word document
Used to extract UK ())not EU) rules of origin from a Word document and insert into DB / JSON

## Implementation steps

- Create and activate a virtual environment, e.g.

  `python3 -m venv venv/`
  
  `source venv/bin/activate`

- Install necessary Python modules via `pip3 install -r requirements.txt`

## Usage

### To create a JSON file from an original Word document:
`python3 create.py <filename> <agreement>`

e.g. 

`python3 create.py roo_uk_eu eu`