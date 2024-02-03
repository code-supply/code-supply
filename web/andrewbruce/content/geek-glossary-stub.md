+++
title = "Geek glossary: stub"
date = 2013-06-06
+++

**Originally published on pivotallabs.com, available with comments on
[archive.org](https://web.archive.org/web/20140717234920/http://pivotallabs.com/geek-glossary-stub/)**.

Over the next few blog posts I intend to bang a few more nails in the coffin of
the widespread misunderstanding of stubs, mocks and spies. Many before me have
had a crack at this (see [Ben Moss’s
post](https://web.archive.org/web/20140717234920/http://pivotallabs.com/means-ends-mocks-stubs/)
for discussion and links), and many of those blog posts and books helped me to
understand what exactly these code design tools are for. I’m still no expert,
but I do think about the application of these tools with unhealthy frequency.

I intend to focus primarily on the usage of these terms inside the Ruby
ecosystem, but these definitions also apply to other languages.

Let’s start with stubs. They’re a useful TDD and design tool. They are not
mocks, and they arguably precede mocks in the history of TDD tooling. Like most
terms surrounded in confusion, there are a few applications of the same idea:

 - Pure stub objects
 - Partial stub objects
 - Stub methods
 - Stub protocols
 - Stub services

 In general, however, a stub is a simplistic implementation of a role that is
 played in a system. The purpose of a stub is to guide execution down a
 particular path, usually to verify that another, unstubbed part of the system
 is doing its job properly.

 ## Pure stub objects

 Perhaps most commonly, stubs are used in a unit test to replace collaborators
 of the system under test. They allow the tester to avoid exercising code that
 belongs to other units. By replacing these collaborators, they give the test
 writer control over the indirect inputs to the system under test.

This sort of language mangling deserves an example. Let’s say we have two
objects in the system with the same interface. They’re swapped out in
production code depending on whether the user wants a cached or uncached URL
fetch.

<dl><dt>URLFetcher</dt><dd> #fetch<br> #pause<br> #resume</dd><dt>CachingURLFetcher</dt><dd> #fetch<br> #pause<br> #resume</dd></dl>

Now, we are testing a user interface that lets someone click on buttons that
perform the above actions. We have an example in RSpec that involves user
error:

```ruby
it "displays an error when the fetcher decides an invalid URL has been entered" do
  fetcher = double('fetcher')
  ui = UserInterface.new(fetcher)
  fetcher.stub(fetch).and_raise_exception(InvalidURL)
  ui.enter_url('http://bad.url/')
  ui.submit
  expect(ui).to display_error('You entered a bad URL!')
end
```

Note how we’re explicitly describing behaviour up to a boundary: this test
doesn’t care how the stub object raises the exception. Note also how we haven’t
stubbed any existing methods on existing classes. This is deliberate: it drives
out polymorphism in the design. The UI object can use any fetcher that responds
to the #fetch message. We should not need to change this test or the UI
implementation when we make a change to what constitutes an invalid URL. We are
free to construct the UI with different objects and we should expect it to work
providing its fetcher collaborator does its job.

We can also say that using a pure stub object helps us to drive composability
into our application. If we have proved that one object can work with any
object that implements an interface, we have a clear contract that a new
implementation needs to fulfil in order to work correctly with that object.

In some languages these contracts are explicit. Java has interfaces and
Objective-C has protocols. In Ruby, interface contracts are implicit. If you
feel the need to enforce a contract, they can be tested with [shared
examples](https://web.archive.org/web/20140717234920/https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-examples).

## Partial stub objects

Partial stub objects are concrete objects that have had some of their
implementation changed. These are popular with Rubyists who believe you
shouldn’t need to change your design when a test barks at you. I’m not one of
those people. However, in some situations it makes sense to stub methods on
existing objects, notably when working with existing code that wasn’t designed
for polymorphism, or to be composable. Rails, in particular, makes using pure
stub objects quite difficult in several places.

## Stub methods

We stubbed a method in our example above. When we stub an existing method on an
object to make a partial stub object, we are ‘stubbing out’ a method. This
particular verb form of stub leads many to believe that stubbing is only
applicable to existing objects. In turn, this leads to some wild arguments that
stubbing is bad practice.

With RSpec’s stubs, it’s important to understand the difference between
Example#stub (now deprecated in favour of Example#double) and Object#stub. The
former creates a pure test double (which can be a pure stub object), and the
latter stubs a method on an existing object (whether it exists or not).
Compare:

```ruby
double('payment gateway')
```

with:

```ruby
PaymentGateway.stub(:process_card) { true }
```

The former returns a new, ‘empty’ stub object that will explode if any message
is called on it. This is an advantage: we usually want a whitelist of messages
that are allowed to be called on an object in a particular test example.
Whitelisting messages forces our tests to expose the messages of our domain in
the tests, which enhances readability and brings complexity to the foreground
when it arises.

The latter couples the test to the concrete implementation, ‘PaymentGateway’,
as well as to the message. In general, it’s best to reduce coupling of type.
This isn’t always a problem, though, and many Rails apps in particular have
test suites that are opinionated about type. See Jim Weirich’s [talks on
connascence](https://vimeo.com/10837903) for a detailed treatment of the
various levels of sin associated with coupling. See
[POODR](https://www.poodr.com/) for a translation into Ruby.

## Stub protocols

I’ve included this section to talk about libraries like
[WebMock](https://github.com/bblimke/webmock). WebMock is used primarily,
despite the confusing name, to stub out low-level network layers. This allows
the programmer to pretend an HTTP request responded in a certain way, timed out
or failed in some way. It can also be used to ‘catch’ any stray code that the
programmer didn’t expect to be calling out to the network.

Whilst WebMock is technically implemented as a bunch of partial stubs, its use
tends not to suffer the downsides of partial stubs listed above, because the
interfaces it stubs are stable and widely used. Further, because WebMock is so
popular, it’s likely to be updated when changes to the Ruby built-ins it stubs
change.

I tend to use WebMock in high-level acceptance tests when I don’t want to call
external services. I want to know that the whole of my application’s stack was
exercised, but don’t particularly care whether a real network request was made
and completed successfully.

## Stub services

Finally, let’s look at stub services. These are wildly different to the rest of
the stub types described, in that they are simplistic implementations of whole
applications that serve some purpose in a system. They may talk HTTP to other
services, but will often have a developer- or product manager-facing user
interface that allows them to be configured to respond in particular ways.

Using stub services allows one system to be tested in isolation from
potentially unreliable external systems. For example, it is tricky to reproduce
a time out error occurring in an external system if you have no control over
that system. But if you can configure the system you are verifying to instead
talk to a replacement service that you do have control over, you can easily
reproduce different situations that you need to accommodate in your
application.
