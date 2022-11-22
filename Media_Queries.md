---
banner: "assets/banners/Dataview-Banner.png"
banner_x: 1.0
banner_y: 1.0
---

# Media Queries

The Obsidian Media Vault markdown contains metadata with tags allowing a variety of queries using the [Dataview](https://blacksmithgu.github.io/obsidian-dataview/) plugin for [Obsidian](https://obsidian.md/). A few example Dataview queries are detailed below.

## Example Dataview Queries

Included here are [several examples](Dataviews/Dataviews.md) of utilizing the Obsidian Dataview plugin to make dynamic queries into a vault. The results of these queries will automatically update when the vault is modified. A few lines of code can produce complex queries with detailed results. It takes a bit of study to learn the Dataview plugin but it is worth it. Hopefully these examples will serve as good starting points in that learning process.

### Example Dataview Beets Query

The markdown for "Fragile" by Yes has the following YAML prelude:

```yaml
---
catalog: Beets
album: Fragile
artist: Yes
format: Digital, Album
albumartist: Yes
genre: Progressive Rock
mb_albumartistid: c1d4f2ba-cf39-460c-9528-6b827d3417a1
mb_albumid: dc792622-a22b-3268-8d7f-8bc27b60b907
mb_releasegroupid: b1176e7b-fa2e-3b28-959a-d8f55b5b6ccf
year: 1977
---
```

#### Dataview Beets query

The above album metadata can be used to perform Dataview queries to search, filter, and retrieve albums as if they are in a database. For example, to produce a table of all albums in this vault by Yes released prior to 1980 add the following to a markdown file in the vault:

````markdown
```dataview
TABLE WITHOUT ID
  link(file.link, album) as Album,
  artist AS "Artist",
  year AS "Year"
FROM "Beets"
WHERE albumartist = "Yes" and year < 1980
SORT artist ASC
```
````

The above Dataview code block produces the following output:

```dataview
TABLE WITHOUT ID
  link(file.link, album) as Album,
  artist AS "Artist",
  year AS "Year"
FROM "Beets"
WHERE albumartist = "Yes" and year < 1980
SORT artist ASC
```

As a list grouped by artist rather than a table, the following dataview codeblock:

````markdown
```dataview
LIST link(rows.file.link, rows.album)
FROM "Beets"
WHERE (albumartist = "Yes" OR albumartist = "XTC") AND
      year < 1990
GROUP BY "**" + albumartist + "**"
```
````

Would list all albums by Yes or XTC released prior to 1990:

```dataview
LIST link(rows.file.link, rows.album)
FROM "Beets"
WHERE (albumartist = "Yes" OR albumartist = "XTC") AND
      year < 1990
GROUP BY "**" + albumartist + "**"
```

### Example Books query

The markdown for "Timequake" by Kurt Vonnegut Jr. has the following YAML prelude:

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

#### Dataview Books query

The above book metadata can be used to perform Dataview queries to search, filter, and retrieve books as if they are in a database. For example, to produce a table of all books in this vault by Kurt Vonnegut Jr. published prior to 1970 add the following to a markdown file in the vault:

````markdown
```dataview
TABLE WITHOUT ID
  link(file.link, title) as Title,
  author AS "Author",
  published AS "Year"
FROM "Books"
WHERE author = "Kurt Vonnegut Jr." and published < 1970
SORT published ASC
```
````

The above Dataview code block produces the following output:

```dataview
TABLE WITHOUT ID
  link(file.link, title) as Title,
  author AS "Author",
  published AS "Year"
FROM "Books"
WHERE author = "Kurt Vonnegut Jr." and published < 1970
SORT published ASC
```

To produce a list grouped by author rather than a table:

````markdown
```dataview
LIST link(rows.file.link, rows.title)
FROM "Books"
WHERE (author = "Kurt Vonnegut Jr." OR author = "Voltaire") AND
      published < 1970
GROUP BY "**" + author + "**"
```
````

Would produce a list of books by Vonnegut or Voltaire published prior to 1970:

```dataview
LIST link(rows.file.link, rows.title)
FROM "Books"
WHERE (author = "Kurt Vonnegut Jr." OR author = "Voltaire") AND
      published < 1970
GROUP BY "**" + author + "**"
```

## See also

- [Dataview: All Beets Albums](Dataviews/Beets_Albums.md)
- [Dataview: Beets Albums released in 1977](Dataviews/Beets_Albums_1977.md)
- [Dataview: Beets Albums released in the 70s](Dataviews/Beets_Albums_70s.md)
- [Dataview: Beets Albums in a Progressive genre](Dataviews/Beets_Progressive.md)
- [Dataview: All 50 Year Old Novels](Dataviews/All_50_Year_Old_Novels.md)
- [Dataview: All Books](Dataviews/All_Books.md)
- [Dataview: All Read Books](Dataviews/All_Read_Books.md)
- [Dataview: All Science Fiction](Dataviews/All_Science_Fiction.md)
- [Dataview: All Unread Books](Dataviews/All_Unread_Books.md)
- [Dataview: Roon Albums](Dataviews/Roon_Albums.md)
- [Dataview: Vinyl Gatefold](Dataviews/Vinyl_Gatefold.md)
- [Dataview: Vinyl Weight](Dataviews/Vinyl_Weight.md)
- [Dataview: Cross Media Types](Dataviews/Cross_Media_Types.md)
- [Index of the Media Vault](Media_Index.md)
- [README](README.md)
- [Process](Process.md)
