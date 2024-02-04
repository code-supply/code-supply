+++
title = "Geek glossary: re-entrant and idempotent"
date = 2013-06-23
+++

**Originally published on pivotallabs.com, available with comments on
[archive.org](https://web.archive.org/web/20150225160556/http://pivotallabs.com/geek-glossary-re-entrant-idempotent/)**.

Whilst writing some [Chef](https://www.chef.io/) recipes for our project’s
Continuous Integration server the other day, my pair and I came across a commit
message to some third party code that claimed to make a routine re-entrant. We
both realised that we didn’t clearly understand the difference between
re-entrancy and idempotency and decided to look the terms up.

Here are my rough re-definitions of the two terms, in the context of Chef, for
the wiki-weary:

<dl>
<dt>Re-entrancy</dt>
<dd>The ability for a routine to complete successfully after a previous, interrupted call.</dd>
<dt>Idempotency</dt>
<dd>The ability for a routine to be called multiple times, producing the same side effects.</dd>
</dl>

Note the difference between mathematical or functional programming idempotency
and the kind of idempotency we care about when writing Chef recipes: a system
for automating machine configuration, such as Chef, necessarily produces side
effects on the machine being configured. We’re not concerned about the result
of pure functions, here.

For the uninitiated, a Chef recipe is a declaration of the configuration of
some computer software, written in a Domain Specific Language (DSL). The DSL is
useful because it hides details. When configuring a new server with an existing
recipe, one would ideally like to ignore details specific to, for example, the
distribution or version of the operating system. Perhaps more importantly for
the system’s maintainer, however, the details of whether certain aspects of the
software have already been configured (or failed to be configured) should also
be hidden.

Idempotency is commonly used to describe the ideal Chef recipe. One advantage
of having a Domain Specific Language (DSL) to create scripts that set up a
machine is to reduce the noise involved with becoming idempotent. The built-in
Chef methods are idempotent by default.

It’s the difference between having to write:

```ruby
unless File.exists?('/etc/mysql/my.cnf')
  File.write('/etc/mysql/my.cnf', File.read('/some/cookbook/path/my.cnf'))
end
```

and:

```ruby
cookbook-file "/etc/mysql/my.cnf" do
  path "my.cnf"
end
```

For our Chef recipes, re-entrancy is important for recovering from failure in
the middle of our scripts, whereas idempotency (which incorporates re-entrancy)
is the property that allows our scripts to work when a system is first
configured, and all of the times after that, without causing unwanted
side-effects on each subsequent call.
