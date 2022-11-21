---
banner: "assets/banners/Dataview-Banner.png"
banner_x: 1.0
banner_y: 1.0
---

# Media Queries

The Obsidian Media Vault markdown contains metadata with tags allowing a variety of queries using the [Dataview](https://blacksmithgu.github.io/obsidian-dataview/) plugin for [Obsidian](https://obsidian.md/). A few example Dataview queries follow.

## Example Beets query

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

### Dataview_Beets_query

The above album metadata can be used to perform Dataview queries to search, filter, and retrieve albums as if they are in a database. For example, to produce a table of all albums in this vault by Yes released prior to 1980 add the following to a markdown file in the vault:

````markdown
```dataview
TABLE
  link(file.link, album) as Album,
  albumartist AS "Artist",
  year AS "Year"
FROM "Beets"
WHERE albumartist = "Yes" and year < 1980
SORT year ASC
```
````

The above Dataview code block produces the following output:

```dataview
TABLE
  link(file.link, album) as Album,
  albumartist AS "Artist",
  year AS "Year"
FROM "Beets"
WHERE albumartist = "Yes" and year < 1980
SORT year ASC
```

## Example Books query

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

### Dataview_Books_query

The above book metadata can be used to perform Dataview queries to search, filter, and retrieve books as if they are in a database. For example, to produce a table of all books in this vault by Kurt Vonnegut Jr. published prior to 1970 add the following to a markdown file in the vault:

````markdown
```dataview
TABLE
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
TABLE
  link(file.link, title) as Title,
  author AS "Author",
  published AS "Year"
FROM "Books"
WHERE author = "Kurt Vonnegut Jr." and published < 1970
SORT published ASC
```

Additional example Dataview Beets and Books queries can be found in the `Dataviews` folder:

- [All Beets Albums](Dataviews/Beets_Albums.md)
- [Beets Albums released in 1977](Dataviews/Beets_Albums_1977.md)
- [Beets Albums released in the 70s](Dataviews/Beets_Albums_70s.md)
- [Beets Albums in a Progressive genre](Dataviews/Beets_Progressive.md)
- [All 50 Year Old Novels](Dataviews/All_50_Year_Old_Novels.md)
- [All Books](Dataviews/All_Books.md)
- [All Read Books](Dataviews/All_Read_Books.md)
- [All Unread Books](Dataviews/All_Unread_Books.md)
- [Roon Albums](Dataviews/Roon_Albums.md)

## See also

- [Index of the Media Vault](Media_Index.md)
- [README](README.md)
- [Process](Process.md)
