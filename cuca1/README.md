## drawbacks

Since this architecture has a main bus connected to everything, we have
to interface every component with tri-state buffers. It might be
incompetence on my part, but I haven't managed to safely do things such
as transfer data between one register and another in one cycle. Maybe
that's fine, though.
