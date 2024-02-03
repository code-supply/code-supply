+++
title = "Geek glossary: mock"
date = 2013-07-07
+++

**Originally published on pivotallabs.com, available with comments on
[archive.org](https://web.archive.org/web/20140717234945/http://pivotallabs.com/geek-glossary-mock/)**.

This is my second post on the trinity of test tools known as ‘test doubles’.
[The first](/geek-glossary-stub/) covered stubs. This one is all about mocks,
which are woefully misunderstood and loathed by many.

If you want to know more about the history of mock objects, get a copy of
[GOOS](http://growing-object-oriented-software.com/). It’s my favourite recent
work on TDD and software design, and it’s written by folks involved in the
invention of mocks.

Unlike my previous post, I’m going to concentrate on pure mock objects. The
disadvantages of partial mocks are similar to those of partial stubs.

First, a definition: a mock is an object that expects messages, and
consequently verifies the outputs of the system under test.

## Why mock?

Mocks were originally designed to avoid the ‘traditional’ TDD practice of
adding code to an object purely for state verification. Their use as a design
tool is worth getting to grips with, even if you don’t intend to use them in
new code, or if you intend to graduate to something else, which we’ll also
touch upon.

You want to mock because you want to write code in a
[Tell-Don’t-Ask](https://pragprog.com/articles/tell-dont-ask) style. You want
to be hit in the head whenever you write code in one object that obsesses over
the state of another. You want to avoid writing code like this:

```ruby
class Barista
  def make_coffee(customer)
    machine = CoffeeMachine.new
    if machine.in_use?
      apologize(to: customer)
    elsif machine.has_water?
      tray = Tray.new
      tray.add_grounds(CoffeeGrounds.new)
      tray.compact!
      machine.attach_tray(tray)
      cup = Cup.new
      machine.place_cup(cup)
      status = machine.release_steam!
      if status.successful?
        serve(cup, to: customer)
      else
        apologize(to: customer)
      end
    end
  end
end
```

If that example was too long, and you didn’t read it: great! You have perfected
the art of bad-code-blindness. The Barista is obsessed with details about the
labourious process of making an espresso. A real-life Barista arguably should
have this disposition, but in code this list of conditions and imperatives is
clumsy. If #make_coffee had been designed from the beginning with judicious use
of mock objects, so the story goes, the designer would have had more feedback
about how bad the code was. Let’s try it:

```ruby
describe Barista do
  it "hits the correct button on the coffee machine" do
    machine = double('coffee making machine')
    order = Order.new
    barista = Barista.new(machine)

    expect(machine).to receive(:brew).with(order)
    barista.order_received(order)
  end

  it "serves coffee when it's ready" do
    americano = Americano.new
    fred = double('customer')
    order = Order.new(fred)
    barista = Barista.new

    expect(fred).to receive(:serve).with(americano)
    barista.order_ready(order, americano)
  end
end
```

After bashing up against the rigidity of the mock (try writing a test like this
yourself to see how it feels), we’ve thought about the domain a little bit, and
decided that the events in the system are the decision making points. With this
in mind, we’ve let the Barista trust the machine to perform its role’s
responsibilities. We expect the Barista to be alerted when coffee is ready, so
that he/she can focus on taking more orders in the meantime. Let’s see how this
could be implemented:

```ruby
class Barista
  def initialize(machine = nil)
    @machine = machine
  end

  def order_received(order)
    @machine.brew(order)
  end

  def order_ready(order, product)
    order.customer.serve(product)
  end
end

Order = Struct.new(:customer)
Americano = Struct.new(:strength)
```

The Barista isn’t perfect, but it is far easier to read, and it’s obvious that
there are more behavioural components in the collaborators. The example would
need further fleshing out if it were to achieve the same effect as the
imperative code we began with.

## When to mock

Mocking isn’t always appropriate. In general, mocking makes sense when you are
testing an object that depends on another object’s behaviour. If the
collaborating object has no behaviour, you probably shouldn’t be expecting that
messages are sent to it.

Value objects (the Structs in the above example) should not be mocked, but
simply instantiated and used in tests. Value objects are just bags of data,
whose equality depends on the values they contain, rather than on some unique
ID, as would be the case for an Entity. Your tests should fail if you are using
values inconsistently across your suite. Values include Money, Distance,
Specification and so on. Some concepts are values in one application and
entities in another. See
[DDD](https://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215)
for a detailed study of these definitions.

You may have heard the mantra “Don’t mock types you don’t own”. This is a
guideline to help avoid pain around changes in external dependencies, such as
libraries. For example, if your application talks to AWS, you should create a
wrapper around the external library that does the work of communicating with
AWS. This interface is under your control and is ‘safe’ to mock. Mocking the
AWS library’s interface directly is likely to result in a lot of broken code
when the library changes. GOOS, linked above, has a good treatment of this.

Another mantra from GOOS is “mock roles, not objects”. In practice, for me this
means choosing a name for the mock in a test that refers generally to the role
a collaborator is playing. So, I would sooner `double('payment gateway')` than
`double('paypal')`. As soon as you mock PayPal, you are in the mindset of
pleasing the external service, with its crazy API, rather than providing a neat
abstraction whose messages are relevant to your particular domain.

## Mocking alternatives

Gary Bernhardt is [leading a charge against mock
objects](https://web.archive.org/web/20140803102251/http://rubyrogues.com/067-rr-gary-bernhardts-testing-style/)
that is much more informed than the usual arguments you may hear (e.g. “I don’t
mock because it’s brittle” – there are ways to mitigate this). In a poorly
paraphrased nutshell, I believe he’s saying that we can use value objects as
the inputs and outputs of objects that we’d otherwise mock. If these objects
are immutable, then we get a cheap way to enforce an interface, and we can
‘isolate’ units of code by testing against these values instead of expecting
messages. In effect, I think the values _become_ the messages.
