---
banner: "assets/banners/Vault-Banner.png"
banner_x: 0.5
banner_y: 0.5
---

# Dataview Queries across multiple media types

This code displays albums by artists with "Jefferson" in their name across all media types. The dataview queries look like the following:

## Albums by artists with "Jefferson" in name

````markdown
```dataview
LIST link(rows.file.link, rows.title)
FROM ""
WHERE contains(artist, "Jefferson")
GROUP BY (file.folder + "<br>" + "**" + artist + "**")
```
````

Which produces the list:

```dataview
LIST link(rows.file.link, rows.title)
FROM ""
WHERE contains(artist, "Jefferson")
GROUP BY (file.folder + "<br>" + "**" + artist + "**")
```

However, not all media types use the same metadata for album name. For example, Beets uses "album" metadata for album name whereas other media types use "title" for album name. We could fix the metadata to make it consistent across all media types or split the Dataview queries out like:

### Beets library

````markdown
```dataview
LIST link(rows.file.link, rows.album)
FROM "Beets"
WHERE contains(artist, "Jefferson")
GROUP BY "**" + artist + "**"
```
````

```dataview
LIST link(rows.file.link, rows.album)
FROM "Beets"
WHERE contains(artist, "Jefferson")
GROUP BY "**" + artist + "**"
```

### CD library

````markdown
```dataview
LIST link(rows.file.link, rows.title)
FROM "CD"
WHERE contains(artist, "Jefferson")
GROUP BY "**" + artist + "**"
```
````

```dataview
LIST link(rows.file.link, rows.title)
FROM "CD"
WHERE contains(artist, "Jefferson")
GROUP BY "**" + artist + "**"
```

### Roon library

````markdown
```dataview
LIST link(rows.file.link, rows.title)
FROM "Roon"
WHERE contains(artist, "Jefferson")
GROUP BY "**" + artist + "**"
```
````

```dataview
LIST link(rows.file.link, rows.title)
FROM "Roon"
WHERE contains(artist, "Jefferson")
GROUP BY "**" + artist + "**"
```

### Vinyl library

````markdown
```dataview
LIST link(rows.file.link, rows.title)
FROM "Vinyl"
WHERE contains(artist, "Jefferson")
GROUP BY "**" + artist + "**"
```
````

```dataview
LIST link(rows.file.link, rows.title)
FROM "Vinyl"
WHERE contains(artist, "Jefferson")
GROUP BY "**" + artist + "**"
```
