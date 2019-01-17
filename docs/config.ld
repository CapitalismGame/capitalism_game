project = "Capitalism Game"
title = "Capitalism Game Reference"
format = "discount"
backtick_references = true
readme = "docs/dev_intro.md"
--boilerplate = true
file = {'mods', exclude = {'mods/mtg'}}
template = "docs/template/"

tparam_alias("pos", "table")
tparam_alias("owner", "string")
tparam_alias("player", "string")
tparam_alias("company", "company.Company")
tparam_alias("account", "banking.Account")
tparam_alias("shop", "shop.Shop")
