[![Actions Status](https://github.com/kaz-utashiro/greple-under/actions/workflows/test.yml/badge.svg)](https://github.com/kaz-utashiro/greple-under/actions)
# NAME

App::Greple::under - greple under-line module

# SYNOPSIS

    greple -Munder::line ...

    greple -Munder::mise ... | greple -Munder::bake

# DESCRIPTION

This module is intended to clarify highlighting points without ANSI
sequencing when highlighting by ANSI sequencing is not possible for
some reason.

The following command searches for a paragraph that contains all the
words specified.

    greple 'license agreements software freedom' LICENSE -p

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/greple-under/main/images/normal.png">
    </p>
</div>

By default, the emphasis should be indicated by underlining it on the
next line.

    greple -Munder::line 'license agreements software freedom' LICENSE -p

Above command will produce output like this:

    ┌───────────────────────────────────────────────────────────────────────┐
    │   The license agreements of most software companies try to keep users │
    │       ▔▔▔▔▔▔▔ ▔▔▔▔▔▔▔▔▔▔         ▔▔▔▔▔▔▔▔                             │
    │ at the mercy of those companies.  By contrast, our General Public     │
    │ License is intended to guarantee your freedom to share and change free│
    │                                       ▔▔▔▔▔▔▔                         │
    │ software--to make sure the software is free for all its users.  The   │
    │ ▔▔▔▔▔▔▔▔                   ▔▔▔▔▔▔▔▔                                   │
    │ General Public License applies to the Free Software Foundation's      │
    │ software and to any other program whose authors commit to using it.   │
    │ ▔▔▔▔▔▔▔▔                                                              │
    │ You can use it for your programs, too.                                │
    └───────────────────────────────────────────────────────────────────────┘

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/greple-under/main/images/under-line.png">
    </p>
</div>

If you want to process the search results before underlining them,
process them in the `-Munder::mise` module and then pass them through
the `-Munder::bake` module.

    greple -Munder::mise ... | ... | greple -Munder::bake

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/greple-under/main/images/mise-bake.png">
    </p>
</div>

# AUTHOR

Kazumasa Utashiro

# LICENSE

Copyright ©︎ 2024 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
