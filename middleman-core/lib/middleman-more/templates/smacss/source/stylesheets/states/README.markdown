# SMACSS

### States

> A state is something that augments and overrides all other styles. For example, an accordion section may be in a collapsed or expanded state. A message may be in a success or error state. [Modules and states] differ in two key ways:

> 1. State styles can apply to layout and/or module styles; and
> 2. State styles indicate a JavaScript dependency.

> - SMACSS, Jonathan Snook

State styles typically refer to styles that only exist on an element for a short period time, for example: styles for invalid form fields would go in `validations.scss`.
