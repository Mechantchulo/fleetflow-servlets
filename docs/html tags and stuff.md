# HTML Tags and UI Patterns Used in This Project

This project uses JSP pages that render HTML5 markup.

## Common Structural Tags

- `<!DOCTYPE html>`, `<html>`, `<head>`, `<body>`
- `<main>`, `<aside>`, `<header>`, `<section>`, `<div>`
- used to build dashboard layout (sidebar + top header + content cards)

## Form Tags

- `<form method="post">`
- `<input>` (`text`, `date`, `datetime-local`, `number`, `password`, `file`)
- `<select>`, `<option>`
- `<textarea>`
- `<button type="submit">`

Used heavily in:

- login/signup
- staff request submission
- timetabling scheduling
- manager allocation actions
- driver trip logs

## Data Display Tags

- `<table>`, `<thead>`, `<tbody>`, `<tr>`, `<th>`, `<td>`
- used for request lists, assigned trips, logs, and summaries

## Navigation and Actions

- `<a href="...">` links for page navigation and PDF exports
- sidebar and top action button sections

## JSP + HTML Mixing

The pages use scriptlets and EL inside HTML:

- scriptlets: `<% ... %>`, `<%= ... %>`
- EL: `${...}`

This allows server-side values (counts, user name, status, row data) to render inside standard HTML tags.

