# Zenodo deposit for review

I prepared the PDF, reproducibility archive and metadata in this folder for review before deposit. The [website article](https://jorgepianosimoes.com/writing/grant-review-precision/) and [study repository](https://github.com/jpsimoes/grant-review-precision) are the public reading and code copies. The PDF and archive belong in one Zenodo record with one publication DOI. Zenodo registers the DOI when the record is published. [Zenodo DOI guidance](https://help.zenodo.org/docs/deposit/describe-records/reserve-doi/)

| File | Use |
| --- | --- |
| `grant-review-precision.pdf` | Article to upload as the primary file. |
| `grant-review-precision-source.zip` | Companion file to upload with the article. Includes the article source, both figures, aggregate tables, scripts, citation and rights notices. |
| `zenodo-metadata.json` | Draft values for the Zenodo record using InvenioRDM field names. |
| `SHA256SUMS` | Checksums for verifying the files and draft metadata supplied for review. |

## Preparing the publication

1. Create a draft upload on Zenodo. Select **Publication → Technical note** and enter the title, author, ORCID, description, keywords and related identifiers from the metadata file. The prepared date is the article's publication date. Use Jorge Piano Simões as my display name.
2. Within the draft, choose **Get a DOI now**. Add the reserved DOI to the article's Data and methods section, the preferred citation in `CITATION.cff`, the README citation, and the website article’s deposit link. The companion ZIP includes the technical README at `methods/README.md` for readers accessing the study through the DOI. A DOI reserved for a draft resolves publicly after publication. [DOI reservation](https://help.zenodo.org/docs/deposit/describe-records/reserve-doi/)
3. Select **CC BY 4.0** and **MIT** in the record’s licences. The description specifies that CC BY applies to the original article, figures and documentation, and MIT to the study code. Source datasets retain their providers' terms. [Zenodo guidance on mixed licences](https://help.zenodo.org/docs/deposit/describe-records/licenses/)
4. From the study root, rebuild the PDF with `python3 scripts/render_article.py` and the source ZIP with `python3 scripts/package_release.py`. To refresh the prepared website checkout, use `python3 scripts/stage_website.py /path/to/website`. Check the DOI, document dates and attribution in the final PDF and website copy.
5. From this directory, regenerate the receipt with `shasum -a 256 grant-review-precision.pdf grant-review-precision-source.zip zenodo-metadata.json > SHA256SUMS`. Run `shasum -a 256 -c SHA256SUMS` to verify the package. Upload the PDF and ZIP to the same draft, review the record preview, and publish when ready.
