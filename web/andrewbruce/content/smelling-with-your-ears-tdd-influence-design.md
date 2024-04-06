+++
title = "Smelling with your ears: TDD techniques to influence your design"
date = 2013-05-12
+++

**Originally published on pivotallabs.com, available with comments on
[archive.org](https://web.archive.org/web/20140718182523/http://pivotallabs.com/smelling-with-ears-tdd-influence-design/)**.

Test Driven Development can be a hard sell. The first pitch is often designed
to entice the buyer with safety features, like:

- “How will you ensure that those bugs don’t creep back in?”
- “Wouldn’t it be nice to know that one change doesn’t break another?”

In conversations between practiced test drivers, though, design topics tend to
pop up:

- “What is this test telling us about the design of our code?”
- “Why is this test boring to write?”
- “Why is this test so slow?”

Then there are really exciting questions, when getting close to a design
breakthrough, like:

- “Is this test telling us we’re lacking polymorphism in our design?”
- “I’m tired of constructing this thing. How can we group this set of arguments
  into an object with a name?”

One distinguishing factor between these types of questions is the level of
trust in TDD. Someone with little trust might be predisposed to abandon testing
before implementation, instead choosing to test afterwards, or not at all. To
such a person yet to be sold on the benefits of TDD, the safety questions make
more immediate sense, while design questions are often met with blank stares.
However, the safety concerns are easily brushed off: it’s a prototype. My team
is so smart we don’t need tests. We need to move fast, so we’ll worry about
tests later.

Explaining the basic advantages of TDD doesn’t always work as a sales pitch,
because those explanations don’t reveal why testing can be difficult, much less
why testing sometimes *ought* to be difficult. Take someone who has never let
the design of their code be influenced by tests: they dislike testing for being
difficult or boring. Encountering resistance in the TDD process, they choose to
forgo the safety advantages of testing, and the design advantages haven’t been
made clear.

As you may have gathered, I’m more excited by the design aspect of TDD and
related tools than by the safety aspect. I’d like to think that if we sold how
TDD can improve the design of code that’s yet to be written, we’d have an
easier time tricking our friends into writing code with regression protection.

## Learning to listen

There is much talk about “listening to the tests” among TDD practitioners. The
listening analogy is apt. Like listening with our ears, the ability to
understand what a test tells us about code quality can improve with practice.
It’s a subtle concept to grasp, and one I frequently find is not well
understood by otherwise experienced developers. This is unfortunate, because
it’s a crucial part of getting rapid feedback on the quality of production
code. By quality, I’m referring primarily to the ability to cope with changing
requirements, as opposed to good coverage of features and edge-cases.

If you can’t hear what your tests are trying to say, there are tools for
cranking up the volume. Below are a couple of my favorites. They’re not
intended as hard-and-fast rules, but as exercises to try out when you’re
frustrated with a test or wondering why it’s getting difficult to test
something.

If you haven’t already, you should read about [known test smells and their
solutions](http://xunitpatterns.com/Test%20Smells.html), because we can
apparently smell with our TDD ears.

## Use your testing framework’s convenience helpers sparingly

In the RSpec world, this often comes down to writing readable examples without
using ‘subject’, ‘let’ or ‘before’. It turns out that straightforward
assignment is usually OK.

As [this Thoughtbot post](https://thoughtbot.com/blog/lets-not) argues, the let
helper effectively introduces Mystery Guests (implicit, hidden fixtures), and
overuse results in slow and fragile tests.

I like to avoid lets, subjects and other test helpers for another reason: if I
can’t stand to repeat myself in examples, I think about how the code that uses
my code will feel. A boring, repetitive test setup might be telling me that my
code has too many dependencies. If I’m frantically stuffing things into the
database and stubbing out web service requests just to allow myself to
construct an object, perhaps the object’s scope is too broad.

If you come across a test that is apparently repetitive, consider tidying the
implementation of the system under test before the test itself. You may find
that the noise in the test can be dramatically reduced with some production
code tweaks.

## Avoid stubbing methods to return values

I owe this one to [Greg Moeck](http://gmoeck.github.io/), who introduced
something like it at the [San Francisco eXtreme Tuesday
Club](https://web.archive.org/web/20140816042552/http://www.meetup.com/pivotal-labs-sf/).

First, a reminder of the definition of stubs versus mocks (to paraphrase Gerard
Meszaros):

1. A stub is a test double that allows you to control the indirect inputs of
   the system under test.
1. A mock is a test double that allows you to test the indirect outputs of the
   system under test.

If you return a value from a stubbed method, you force your production code to
depend on a blocking, synchronous call. If you could otherwise send a message
and not expect an immediate response, you permit your design to (now or in the
future) be asynchronous.

Further to that, if you instead use a mock to expect an output to the
collaborator you were previously stubbing, you can more cleanly divide your
testing into inputs and outputs of the system under test. It’s the difference
between:

```ruby
it "ensures user is authentic before performing the action" do
  user = stub('user')
  authenticator = stub('authenticator')
  authenticator.stub(:authentic_user?).with(user) { true }
  action = Action.new(user)
  action.perform
  expect(action).to be_complete
end
```

and:

```ruby
it "ensures the user is authentic when action is requested" do
  user = stub('user')
  authenticator = mock('authenticator') # assume the player of this role knows who to tell when authentication succeeds or fails
  authenticator.should_receive(:authenticate_user).with(user)
  action = Action.new(user)
  action.perform
end

it "performs an action once a user has been authenticated" do
  action = Action.new(stub('unauthenticated user'))
  authenticated_user = stub('user')
  action.user_successfully_authenticated(user)
  expect(action).to be_complete
end
```

The code that passes the second set of examples is in better shape for when you
need to queue requests to the authenticator and complete the action
asynchronously. It uses a [“tell, don’t
ask”](https://web.archive.org/web/20140708203233/http://pragprog.com/articles/tell-dont-ask)
style. The fact that an explicit message is sent to the system under test
(‘user_successfully_authenticated’) makes it clear to the reader that the
request for authentication and the triggering of the action are separate bits
of work. It’s someone else’s business whether I get told about the successful
authentication, and how many steps are taken before I’m told.

There are several more techniques I’d like to tell you about, but this post is
getting a bit long in the tooth. Maybe next time. Happy listening!
