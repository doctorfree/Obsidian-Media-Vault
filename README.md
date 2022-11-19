---
banner: "assets/banners/Obsidian-Banner.png"
banner_x: 0.5
banner_y: 0.5
---

# Obsidian Media Vault

This repository is organized as an Obsidian vault containing Media descriptions in markdown format. It can be viewed using any markdown viewer (e.g. almost any browser) but if Obsidian is used then many additional features will be available including queries using the [Dataview](https://blacksmithgu.github.io/obsidian-dataview/) plugin for [Obsidian](https://obsidian.md/).

The `Obsidian-Media-Vault` repository reflects the partial contents of my personal library of books, cds, digital music, and records. As such, it may be relevant only to a few. However, the process by which this repository was created and curated as well as the tools used in its creation and curation may be useful to a wider audience. I am making it public and freely licensed so that others may examine, adapt, clone, and use in whatever manner they choose. See the [description of Process](Process.md) for an overview of the process and tools employed in the creation of this repository.

**[Note:]** This is a fairly large repository, over 4GB, half of which is album and book cover art. The Obsidian mobile applications may not be able to handle this size vault. The desktop Obsidian application for Windows, Mac, or Linux are recommended for use with this vault. Each of the components of this "super vault" have been split out into their own smaller vaults. To download and view these "sub-vaults", see:

- [Obsidian Beets Vault](https://github.com/doctorfree/Obsidian-Beets-Vault)
- [Obsidian Books Vault](https://github.com/doctorfree/Obsidian-Books-Vault)
- [Obsidian CD Vault](https://github.com/doctorfree/Obsidian-CD-Vault)
- [Obsidian Roon Vault](https://github.com/doctorfree/Obsidian-Roon-Vault)
- [Obsidian Vinyl Vault](https://github.com/doctorfree/Obsidian-Vinyl-Vault)

Get started browsing the [Obsidian Media Vault](Media_Index.md).

## Table of Contents

- [Usage](#usage)
- [Dataview](#dataview)
    - [Screenshot](#screenshot)
- [Libraries](#libraries)
    - [Apple](#apple)
    - [Beets](#beets)
    - [Books](#books)
    - [CD](#cd)
    - [Roon](#roon)
        - [Playlists](#playlists)
    - [Vinyl](#vinyl)
- [Structure](#structure)
- [Process](#process)
- [Obsidian Plugins](#obsidian_plugins)
- [See also](#see_also)

## Usage

### **For the optimal experience, open this vault in Obsidian!**

1. [Download the vault](https://github.com/doctorfree/Obsidian-Media-Vault/releases/latest)
3. Open the vault in Obsidian via "Open another vault -> Open folder as vault"
4. Trust us. :) 
5. When Obsidian opens the settings, hit the switch on "Dataview" to enable the plugin
6. Done! The Obsidian Media Vault is now available to you in its purest and most useful form!

## Dataview

The Obsidian Media Vault has been curated with metadata allowing queries to be performed using the Obsidian Dataview plugin. Sample queries along with the code used to perform them can be viewed in the [Media Queries](Media_Queries.md) document.

Additional visual representations of the Media Vault, also based upon Dataview queries, are provided by the [Excalibrain](https://github.com/zsviczian/excalibrain) Obsidian plugin.

The Obsidian Media Vault markdown contains metadata with tags allowing a variety of Obsidian Dataview queries. For example, the markdown of the book "Timequake" by Kurt Vonnegut Jr. has the following YAML prelude:

```yaml
---
bookid: 9594
title: Timequake
author: Kurt Vonnegut Jr.
authors: 
isbn: 0099267543
isbn13: 9780099267546
rating: 4
avgrating: 3.72
publisher: Vintage Classics
binding: Paperback
pages: 219
published: 1997
shelves: science-fiction, novels, vonnegut
shelf: read
review: 
---
```

The above book metadata can be used to perform Dataview queries to search, filter, and retrieve books as if they are in a database. For example, to produce a table of all books in this vault by Kurt Vonnegut Jr. published prior to 1970 add the following to a markdown file in the vault:

````markdown
```dataview
TABLE
  title AS "Title",
  author AS "Author",
  published AS "Year"
FROM "Books"
WHERE author = "Kurt Vonnegut Jr." and published < 1970
SORT published ASC
```
````

### Screenshot

![Dataview Queries](assets/dataview.png)

Sample queries along with the code used to perform them can be viewed in the [Media Queries](Media_Queries.md) document.

## Libraries

The Obsidian Media Vault includes entries from several media libraries including my Books, CDs, Vinyl records, Apple Music, Roon Audio System, and Beets music libraries. See the [Process section below](#process) for details on this vault setup procedure.

### Apple

An XML format export of an Apple Music library can be generated in Apple Music by selecting `File -> Library -> Export Library`. Included in this repository are several scripts used to convert and process the Apple Music XML export into Markdown. These can be found in the `Tools/Apple/` folder.

### Beets

To index and categorize a [Beets music library](https://beets.io/), the [MusicPlayerPlus](https://github.com/doctorfree/MusicPlayerPlus#readme) package can be used. MusicPlayerPlus provides command line utilities that can be used to query, list, and manage various aspects of a Beets library. The scripts used to produce the Beets markdown for this repository can be found in `Tools/Beets/`. See [Beets Albums by Artist](Beets_Albums_by_Artist.md) to view an index of Beets albums by artist.

### Books

The 'Books' subfolder of this Obsidian vault was created by exporting my Goodreads library of books to CSV. I then used [csvkit](https://csvkit.readthedocs.io/en/latest) and command line tools to convert the CSV format Goodreads data to Markdown. Each Markdown document created in this way contains extensive metadata that can be used to query the vault with Dataview. See [Books_by_Author](Books_by_Author.md) to view an index of books by author.

### CD

My CDs are catalogued in [Collectorz](https://cloud.collectorz.com). See [Process.md](Process.md) for details on how to export a Collectorz library. See [CD_by_Artist](CD_by_Artist.md) to view an index of CDs by artist.

### Roon

To index and categorize a [Roon Audio System](https://roonlabs.com) library, the [RoonCommandLine](https://github.com/doctorfree/RoonCommandLine#readme) package was used. RoonCommandLine provides command line utilities that can be used to list various aspects of a Roon library. The scripts used to produce the Roon markdown for this repository can be found in `Tools/Roon/`. See [Beets Albums by Artist](Beets_Albums_by_Artist.md) to view an index of Beets albums by artist.

#### Playlists

Playlists from the Roon Audio System were generated using the [RoonCommandLine](https://github.com/doctorfree/RoonCommandLine#readme) command `roon -l playtracks`.

### Vinyl

My vinyl records are catalogued in [Discogs](https://www.discogs.com). See [Process.md](Process.md) for details on how to export a Discogs library. See [Vinyl_by_Artist](Vinyl_by_Artist.md) Albums by Artist](Beets_Albums_by_Artist.md) to view an index of vinyl albums by artist.

## Structure

The Books sub-vault is organized by author subfolders. For example, all books by Kurt Vonnegut Jr. are in the `Books/Kurt_Vonnegut_Jr/` folder.

## Process

See the [Process](Process.md) document for a detailed description of the tools and process used to generate this vault.

## Obsidian_Plugins

Obsidian community plugins we have found useful and can recommend include the following:

- [Contextual Typography](https://github.com/mgmeyers/obsidian-contextual-typography): Enables enhanced preview typography
- [Dataview](https://github.com/blacksmithgu/obsidian-dataview): Treats an Obsidian Vault as a database from which you can query
- [Excalibrain](https://github.com/zsviczian/excalibrain): An interactive structured mind-map of an Obsidian vault
- [Excalidraw](https://github.com/zsviczian/obsidian-excalidraw-plugin): Edit and view Excalidraw in Obsidian
- [Hider](https://github.com/kepano/obsidian-hider): Hides various elements of the UI
- [Hover-editor](https://github.com/nothingislost/obsidian-hover-editor): Turns the hover popover into a full featured editor
- [Pandoc](https://github.com/OliverBalfour/obsidian-pandoc): Adds command palette options to export your notes to a variety of formats
- [Quickadd](https://github.com/chhoumann/quickadd): Quickly add content to a vault
- [Shellcommands](https://github.com/Taitava/obsidian-shellcommands): Define and run shell commands
- [Style Settings](https://github.com/mgmeyers/obsidian-style-settings): Enables theme customization
- [Templater](https://github.com/SilentVoid13/Templater): Defines a powerful templating language

## See_also

- [Index of the Media Vault](Media_Index.md)
- [Media Queries](Media_Queries.md)
- [Process](Process.md)

![Alt](https://repobeats.axiom.co/api/embed/03ba6f6b7c7508d79cc789792624f997c863b2c3.svg "Repobeats analytics image")
