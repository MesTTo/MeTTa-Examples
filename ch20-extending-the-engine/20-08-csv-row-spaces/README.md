# Query a CSV file as a space

```metta
!(import! &self (library lib_csv))
!(import! &self (library lib_file))
!(replace-file! "sales.csv" "001,12.50\n002,7.25\n")
!(bind! &sales (csv-space "sales.csv"))
!(test (sort-atom (collapse (match &sales (row $id $amount) ($id $amount))))
       (("001" "12.50") ("002" "7.25")))
```

Every cell is a string, so parse a column that means a number.

```metta
!(import! &self (library lib_csv))
!(import! &self (library lib_file))
!(import! &self (library lib_string))
!(replace-file! "prices.csv" "001,12.50\n")
!(bind! &prices (csv-space "prices.csv"))
!(test (collapse (match &prices (row $id $amount) (parse-number $amount))) (12.5))
```

| | |
|---|---|
| effect class | `readOnlyLookup` |
| writes | none; copy row atoms into a native space to edit them |
| open files | none; each query opens its own stream and releases it on completion, error or early termination |
| a later query | reads later file contents |
| validation | only the records a query consumes, so an early match does not scan the rest |
| headers | ordinary row atoms; nothing is silently discarded |
| repeated rows | repeated answers |
| text | UTF-8, comma separators, doubled-quote escaping; quoted line endings keep their exact characters |

| Refusal | When |
|---|---|
| `csv_malformed_row` | a different width or an unterminated quoted field, with its logical record number |
| `csv_file_missing` | no such file |
| `csv_permission_denied` | unreadable |

Each names its remedy.

`01-csv-space.metta` beside this file runs under the gate, creating its own
temporary CSV and removing it after three queries.

[The CSV library](../../../lib/lib_csv/README.md) also parses and encodes text,
reads field lists, writes and appends files, and accepts explicit dialects. Use
`(width any)` when variable widths are intentional.
