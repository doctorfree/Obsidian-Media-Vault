---
banner: "assets/banners/Dataview-Banner.png"
banner_x: 1.0
banner_y: 1.0
---

# Beets Albums released in 1977

This code displays all albums from the Beets folder released in the 70s sorted by year.

````markdown
```dataview
TABLE WITHOUT ID
  artist AS "Artist",
  link(file.link, album) as Album,
  genre AS "Genre",
  year AS "Year"
FROM "Beets"
WHERE artist != null AND album != null AND year > 1969 AND year < 1980
SORT year ASC
```
````

Output of above code:

```dataview
TABLE WITHOUT ID
  artist AS "Artist",
  link(file.link, album) as Album,
  genre AS "Genre",
  year AS "Year"
FROM "Beets"
WHERE artist != null AND album != null AND year > 1969 AND year < 1980
SORT year ASC
```
