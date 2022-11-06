---
title: "<%- item.title %>, <%- item.author %>"
isbn: <%- item.isbn %>
rating: <%- item.rating %>
average: <%- item.average %>
pages: <%- item.pages %>
date: <%- item.date %>
---

# <%- item.title %>

By **<%- item.author %>**

## Book data

[GoodReads ID/URL](https://www.goodreads.com/book/show/<%- item.id %>)

- ISBN13: <%- item.isbn %>
- Rating: <%- item.rating %> (average: <%- item.average %>)
- Published: <%- item.year %>
- Pages: <%- item.pages %>
- Date added/read: <%- item.date %>

## Review

<%- item.review -%>