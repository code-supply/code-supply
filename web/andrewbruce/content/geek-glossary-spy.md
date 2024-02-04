+++
title = "Geek glossary: spy"
date = 2013-07-08
+++

**Originally published on pivotallabs.com, available with comments on
[archive.org](https://web.archive.org/web/20140717110952/http://pivotallabs.com/geek-glossary-spy/)**.

So spies are pretty easy. They’re test doubles, used like
[mocks](/geek-glossary-mock/), but instead of setting up expectations before an
event, you check the state of the spy after the event, since it records every
known message sent to it.

Spy frameworks haven’t taken off in Ruby as much as in other languages, such as
JavaScript. So let’s look at [Jasmine](https://github.com/jasmine/jasmine), a
Pivotal Labs tool, similar in style to RSpec. It has some built-in spying
features.

The word ‘spy’ might lead you believe that you should ‘spy’ upon existing
objects. You can do that:

```javascript
describe("User (awesome god object)", function() {
    it("creates a cart when signed up", function() {
        var user = new User();
        spyOn(Cart, "create");
        user.signUp("someusername", "somepassword");
        expect(Cart.create).toHaveBeenCalledWith({user: user});
    });
});
```

This is all very well, but as I’ve suggested in my previous posts about
[stubs](/geek-glossary-stub/) and [mocks](/geek-glossary-mock/), you might want
to try a pure spy object, to drive out cleaner separation of object roles.
Let’s look at the mock post’s example translated to Jasmine:

```javascript
describe("Barista", function() {
    it("hits the correct button on the coffee machine", function() {
        var machine = jasmine.createSpyObj('coffee making machine', ['brew']),
            order = new Order(),
            barista = new Barista(machine);

        barista.orderReceived(order);
        expect(machine.brew).toHaveBeenCalledWith(order);
    });

    it("serves coffee when it's ready", function() {
        var americano = new Americano(),
            fred = jasmine.createSpyObj('customer', ['serve']),
            order = new Order(fred),
            barista = new Barista();

        barista.orderReady(order, americano);
        expect(fred.serve).toHaveBeenCalledWith(americano);
    });
});
```

In addition to spy objects that come pre-packaged with methods whose calls are
recorded, Jasmine allows you to spy on any function, or to create pure spy
functions. The latter is especially useful in JavaScript, since it’s a common
pattern to pass a function as a callback to an asynchronous call. You can
create a pure spy function like so:

```javascript
var spyFunc = jasmine.createSpy();
```

spyFun now behaves just like fred.serve and machine.brew, above.

So why use spies over mocks? I think it comes down to taste, as well as
availability of tools. If you’re used to verifying behaviour after a call to
the system under test, spies might feel more intuitive.

Spies can be more verbose than mocks, at least in their current incarnation in
Jasmine. In the above examples, we had to both declare the method names on the
spy objects as well as verify the methods had been called.

One distinct advantage of spies is that they’re a pretty useful debugging tool
that can be invoked from inside a test. If you’re back-filling tests (shudder)
and need to know what calls have been made to a function, you can spy on it and
inspect the state of the spy from a REPL. Chances are good that the work to set
up the spy will be used in the test anyway. When using mocks, however,
debugging usually has to take place in the production code.
