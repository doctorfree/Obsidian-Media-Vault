---
banner: "assets/banners/Dataview-Banner.png"
banner_x: 1.0
banner_y: 1.0
---

# All Beets Albums

This code displays all albums from the Beets folder sorted by artist.

````markdown
```dataview
TABLE WITHOUT ID
  artist AS "Artist",
  link(file.link, album) as Album,
  year AS "Year"
FROM "Beets"
WHERE artist != null AND album != null
SORT artist ASC
```
````

Output of above code:

```dataview
TABLE WITHOUT ID
  artist AS "Artist",
  link(file.link, album) as Album,
  year AS "Year"
FROM "Beets"
WHERE artist != null AND album != null
SORT artist ASC
```
