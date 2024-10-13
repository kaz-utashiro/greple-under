[![Actions Status](https://github.com/kaz-utashiro/greple-under/actions/workflows/test.yml/badge.svg)](https://github.com/kaz-utashiro/greple-under/actions)
# NAME

App::Greple::under - greple under-line module

# SYNOPSIS

    greple -Munder::line ...

    greple -Munder ... | greple -Munder::line ^

# DESCRIPTION

**greple**'s **under** module emphasizes matched text not in the same line
but in the next line without ANSI effect.

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/greple-under/main/images/normal.png">
    </p>
</div>

<div>
    <p>
    <img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/greple-under/main/images/under-line.png">
    </p>
</div>

# AUTHOR

Kazumasa Utashiro

# LICENSE

Copyright ©︎ 2024 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
