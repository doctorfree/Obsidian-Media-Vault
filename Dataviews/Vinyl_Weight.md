---
banner: "assets/banners/Vinyl-Banner.png"
banner_x: 0.5
banner_y: 0.5
---

# Vinyl Albums by Weight

This code displays vinyl albums with weight metadata from the Vinyl folder sorted by artist. The dataview queries look like the following:

````markdown
```dataview
LIST link(rows.file.link, rows.title)
FROM "Vinyl"
WHERE artist != null AND
      title != null AND
      contains(weight, "180")
GROUP BY "**" + artist + "**"
```
````

Where "180" is replaced by the appropriate weight in grams.

## 150 Gram Vinyl Albums

```dataview
LIST link(rows.file.link, rows.title)
FROM "Vinyl"
WHERE artist != null AND
      title != null AND
      contains(weight, "150")
GROUP BY "**" + artist + "**"
```

## 180 Gram Vinyl Albums

```dataview
LIST link(rows.file.link, rows.title)
FROM "Vinyl"
WHERE artist != null AND
      title != null AND
      contains(weight, "180")
GROUP BY "**" + artist + "**"
```

## 200 Gram Vinyl Albums

```dataview
LIST link(rows.file.link, rows.title)
FROM "Vinyl"
WHERE artist != null AND
      title != null AND
      contains(weight, "200")
GROUP BY "**" + artist + "**"
```
