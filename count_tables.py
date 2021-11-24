import docx


def main():
    document = docx.Document("resources/source/roo_overseas.docx")
    table_count = len(document.tables)
    print(str(table_count))

if __name__ == "__main__":
    main()
