+++
title = "Going fast"
date = 2013-06-30
+++

**Originally published on pivotallabs.com, available with comments on
[archive.org](https://web.archive.org/web/20140718060015/http://pivotallabs.com/going-fast/)**.

So you have a team of four developers and a product manager. You seem to be in
a good place: you’re using Pivotal Tracker to keep visibility into your backlog
of work, your velocity is high and, more importantly, constant. Releases went
well and the team you’ve built can efficiently mutate your software to suit
every new product idea. It’s a proven recipe for success!

But now you have some more money and want to go faster. You decide that you
need to grow the team. You add two more pairs in the hope of getting twice as
much done.

Two months down the line, you realise things aren’t going quite as fast as
predicted. Developers are treading on each other’s toes and build time is
rapidly increasing because lots of slow high-level (or even slow unit-level)
tests are being added. You need a solution to these problems, and you decide to
mitigate developer work clashes and accidental double-work by carving the
backlog into ‘tracks’. Instead of developers working on stories as they go, by
picking them off the top of the backlog, work is allocated according to clearly
defined areas of the system that you believe are separate enough to avoid
people bumping into each other.

In addition to the tracks of work, you start to make stories incremental,
instead of iterative: one story might focus on JavaScript and CSS and stop at
the point where a form handler needs programming; the next story assumes the
work on the front-end is finished and starts at the form-handling level,
implementing back-end controller and model code.

These techniques seem to solve the immediate problems you’re facing. It’s
another winning formula, so you add another two pairs, bringing you up to six.
Now you can really rip through features!

New problems arise. Now the build is *really* slow, and developers choose to run
subsections of the test suite before a check-in. Long periods of red builds
result. The incremental stories are feeding this problem: one pair covers their
behinds with high-level tests, and the pair responsible for the connecting
story is so busy working out how their piece fits into the puzzle that they
don’t have the mental space to hunt down and extend the previous pair’s test.
You have two or more high-level tests for the same feature, and duplicate
implementations of components. Nobody has visibility into this, because
everybody is busy working out what their story means, or is busy implementing
it. The new developers on the team are busy enough working out how the product
works.New problems arise. Now the build is really slow, and developers choose
to run subsections of the test suite before a check-in. Long periods of red
builds result. The incremental stories are feeding this problem: one pair
covers their behinds with high-level tests, and the pair responsible for the
connecting story is so busy working out how their piece fits into the puzzle
that they don’t have the mental space to hunt down and extend the previous
pair’s test. You have two or more high-level tests for the same feature, and
duplicate implementations of components. Nobody has visibility into this,
because everybody is busy working out what their story means, or is busy
implementing it. The new developers on the team are busy enough working out how
the product works.

It no longer makes sense for developers to look at the backlog of work, because
it’s meaningless to them: on a given day, a pair is assigned to work on a
specific track, so they look at the stories labeled as such.

What happens next? The above situation either continues, gets worse, or it
improves. The latter only happens if something changes. Next up, you try to
split the team.

The whole team wants this, but there are forces against it: emotional ties
within the team, worries about practicality, and no obvious place to split in
the code. Everything was previously developed with the assumption that everyone
understood all components of the system.

Eventually a split occurs anyway. Meetings are a lot shorter, and it feels easy
to go back to iterative stories. Now, however, there’s not enough
synchronization and the two teams are still working on the same code.

If you’re reading this thinking that I have some solutions to these problems,
you’re wrong. Assuming that there is an alternative strategy, what is it? Do we
enforce large stories to avoid the ‘incremental story’ problems described
above? Is more architecture up-front needed to predict required team splits?
Perhaps the issues I’ve described are natural and unavoidable consequences of
going fast. Perhaps Fred Brooks is still right, even given the sophisticated
team organisational structures we have now.

Can we go fast and keep control?
