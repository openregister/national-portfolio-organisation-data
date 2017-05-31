# Download from the Arts Council website and shape into a tsv

library(tidyverse)
library(readxl)

list_path <- "../lists/arts-council/source.xlsx"
tsv_path <- "../data/national-portfolio-organisation/national-portfolio-organisation.tsv"

if (!file.exists(tsv_path)) {
  download.file("http://www.artscouncil.org.uk/sites/default/files/download-file/National-portfolio_Major-partner-musuems_2015-18_investment_0.xlsx", list_path)
}

list_data <- read_excel("../lists/arts-council/source.xlsx")

# TODO:
# * What to call 'Alternative Name'?
# * What to do about area/region?

new_field_names <-
c("name",
  "alternative-name",
  "funding-programme",
  "area",
  "region",
  "discipline",
  "funded-2012-15",
  "funding-2012-13",
  "funding-2013-14",
  "funding-2014-15",
  "funding-total",
  "grant-2015-16",
  "grant-2016-17",
  "grant-2107-18",
  "grant-total",
  "funding-source",
  "cash-change-2014-15--2015-16",
  "cash-change-2012-15--2015-18",
  "real-change-2014-15--2015-16",
  "real-change-2012-15--2015-18",
  "notes",
  "local-authority-name",
  "website")

colnames(list_data) <- new_field_names

# Build a list of nationwide local authorities, to check that the arts council
# list links to them
local_authority_sct <- read_tsv("../../local-authority-data/data/local-authority-sct/local-authority-sct.tsv", col_types = "ccccDD") %>% rename(`local-authority` = `local-authority-sct`)
principal_local_authority <- read_tsv("../../local-authority-data/data/principal-local-authority/principal-local-authority.tsv", col_types = "ccccDD") %>%
  rename(`local-authority` = `principal-local-authority`)
local_authority_eng <- read_tsv("../../local-authority-data/data/local-authority-eng/local-authorities.tsv", col_types = "ccccDD") %>% rename(`local-authority` = `local-authority-eng`)
local_authority_nir <- read_tsv("../../local-authority-data/data/local-authority-nir/local-authorities.tsv", col_types = "cccDD") %>% rename(`local-authority` = `local-authority-nir`)
local_authority <- bind_rows(local_authority_sct, principal_local_authority, local_authority_eng, local_authority_nir) %>% select(`local-authority`, `name`, `official-name`)

# All the local authorities match ones in existing registers (output should have
# zero rows, or only an NA row)
list_data %>%
  distinct(`local-authority-name`) %>%
  left_join(local_authority,
            by = c(`local-authority-name` = "name")) %>%
  filter(is.na(`local-authority-name`))

# Disciplines are meaningful and not misspelled
list_data %>%
  count(discipline) %>%
  arrange(desc(n))

# Write the tsv
write_tsv(list_data, tsv_path, na = "")
