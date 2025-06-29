local M = {}

M.quotes = {
  { "Code is like humor. When you have to explain it, it's bad." },
  {
    "There are only 10 types of people: those who understand binary and those who don't.",
  },
  {
    'Any fool can write code that a computer can understand. Good programmers write code that humans can understand.',
  },
  { 'First, solve the problem. Then, write the code.' },
  { 'Experience is the name everyone gives to their mistakes.' },
  { 'In order to be irreplaceable, one must always be different.' },
  { 'Java is to JavaScript what car is to Carpet.' },
  { 'Knowledge is power, but applied knowledge is wisdom.' },
  {
    'Debugging is twice as hard as writing the code in the first place. Therefore, if you write the code as cleverly as possible, you are, by definition, not smart enough to debug it.',
    'Brian Kernighan',
  },
  { "If you don't finish then you're just busy, not productive." },
  {
    'Adapting old programs to fit new machines usually means adapting new machines to behave like old ones.',
    'Alan Perlis',
  },
  {
    'Fools ignore complexity. Pragmatists suffer it. Some can avoid it. Geniuses remove it.',
    'Alan Perlis',
  },
  {
    'It is easier to change the specification to fit the program than vice versa.',
    'Alan Perlis',
  },
  {
    'Simplicity does not precede complexity, but follows it.',
    'Alan Perlis',
  },
  {
    'Optimization hinders evolution.',
    'Alan Perlis',
  },
  {
    'Recursion is the root of computation since it trades description for time.',
    'Alan Perlis',
  },
  {
    'It is better to have 100 functions operate on one data structure than 10 functions on 10 data structures.',
    'Alan Perlis',
  },
  {
    'There is nothing quite so useless as doing with great efficiency something that should not be done at all.',
    'Peter Drucker',
  },
  {
    "If you don't fail at least 90% of the time, you're not aiming high enough.",
    'Alan Kay',
  },
  {
    'I think a lot of new programmers like to use advanced data structures and advanced language features as a way of demonstrating their ability. I call it the lion-tamer syndrome. Such demonstrations are impressive, but unless they actually translate into real wins for the project, avoid them.',
    'Glyn Williams',
  },
  {
    'I would rather die of passion than of boredom.',
    'Vincent Van Gogh',
  },
  {
    'If a system is to serve the creative spirit, it must be entirely comprehensible to a single individual.',
  },
  {
    "The computing scientist's main challenge is not to get confused by the complexities of his own making.",
    'Edsger W. Dijkstra',
  },
  {
    "Progress in a fixed context is almost always a form of optimization. Creative acts generally don't stay in the context that they are in.",
    'Alan Kay',
  },
  {
    'The essence of XML is this: the problem it solves is not hard, and it does not solve the problem well.',
    'Phil Wadler',
  },
  {
    'A good programmer is someone who always looks both ways before crossing a one-way street.',
    'Doug Linder',
  },
  {
    'Patterns mean "I have run out of language."',
    'Rich Hickey',
  },
  {
    'Always code as if the person who ends up maintaining your code is a violent psychopath who knows where you live.',
    'John Woods',
  },
  {
    'Unix was not designed to stop its users from doing stupid things, as that would also stop them from doing clever things.',
  },
  {
    'Contrary to popular belief, Unix is user friendly. It just happens to be very selective about who it decides to make friends with.',
  },
  {
    'Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away.',
  },
  {
    'There are two ways of constructing a software design: One way is to make it so simple that there are obviously no deficiencies, and the other way is to make it so complicated that there are no obvious deficiencies.',
    'C.A.R. Hoare',
  },
  {
    "If you don't make mistakes, you're not working on hard enough problems.",
    'Frank Wilczek',
  },
  {
    "If you don't start with a spec, every piece of code you write is a patch.",
    'Leslie Lamport',
  },
  {
    'Caches are bugs waiting to happen.',
    'Rob Pike',
  },
  {
    'Abstraction is not about vagueness, it is about being precise at a new semantic level.',
    'Edsger W. Dijkstra',
  },
  {
    "dd is horrible on purpose. It's a joke about OS/360 JCL. But today it's an internationally standardized joke. I guess that says it all.",
    'Rob Pike',
  },
  { 'All loops are infinite ones for faulty RAM modules.' },
  {
    'All idioms must be learned. Good idioms only need to be learned once.',
    'Alan Cooper',
  },
  {
    'For a successful technology, reality must take precedence over public relations, for Nature cannot be fooled.',
    'Richard Feynman',
  },
  {
    'If programmers were electricians, parallel programmers would be bomb disposal experts. Both cut wires.',
    'Bartosz Milewski',
  },
  {
    'Computers are harder to maintain at high altitude. Thinner air means less cushion between disk heads and platters. Also more radiation.',
  },
  {
    'Almost every programming language is overrated by its practitioners.',
    'Larry Wall',
  },
  {
    'Fancy algorithms are slow when n is small, and n is usually small.',
    'Rob Pike',
  },
  {
    'Methods are just functions with a special first argument.',
    'Andrew Gerrand',
  },
  { 'Care about your craft.' },
  { "Provide options, don't make lame excuses." },
  { 'Be a catalyst for change.' },
  { 'Make quality a requirements issue.' },
  { 'Critically analyze what you read and hear.' },
  { "DRY - Don't Repeat Yourself." },
  { 'Eliminate effects between unrelated things.' },
  { 'Use tracer bullets to find the target.' },
  { 'Program close to the problem domain.' },
  { 'Iterate the schedule with the code.' },
  { 'Use the power of command shells.' },
  { 'Always use source code control.' },
  { "Don't panic when debugging" },
  { "Don't assume it - prove it." },
  { 'Write code that writes code.' },
  { 'Design With contracts.' },
  { 'Use assertions to prevent the impossible.' },
  { 'Finish what you start.' },
  { "Configure, don't integrate." },
  { 'Analyze workflow to improve concurrency.' },
  { 'Always design for concurrency.' },
  { 'Use blackboards to coordinate workflow.' },
  { 'Estimate the order of your algorithms.' },
  { 'Refactor early, refactor often.' },
  { 'Test your software, or your users will.' },
  { "Don't gather requirements - dig for them." },
  { 'Abstractions live longer than details.' },
  { "Don't think outside the box - find the box." },
  { 'Some things are better done than described.' },
  { "Costly tools don't produce better designs." },
  { "Don't use manual procedures." },
  { "Coding ain't done 'til all the Tests run." },
  { 'Test state coverage, not code coverage.' },
  { 'English is just a programming language.' },
  { "Gently exceed your users' expectations." },
  { 'Think about your work.' },
  { "Don't live with broken windows." },
  { 'Remember the big picture.' },
  { 'Invest regularly in your knowledge portfolio.' },
  { "It's both what you say and the way you say it." },
  { 'Make it easy to reuse.' },
  { 'There are no final decisions.' },
  { 'Prototype to learn.' },
  { 'Estimate to avoid surprises.' },
  { 'Keep knowledge in plain text.' },
  { 'Use a single editor well.' },
  { 'Fix the problem, not the blame.' },
  { '"select" isn\'t broken.' },
  { 'Learn a text manipulation language.' },
  { "You can't write perfect software." },
  { 'Crash early.' },
  { 'Use exceptions for exceptional problems.' },
  { 'Minimize coupling between modules.' },
  { 'Put abstractions in code, details in metadata.' },
  { 'Design using services.' },
  { 'Separate views from models.' },
  { "Don't program by coincidence." },
  { 'Test your estimates.' },
  { 'Design to test.' },
  { "Don't use wizard code you don't understand." },
  { 'Work with a user to think like a user.' },
  { 'Use a project glossary.' },
  { "Start when you're ready." },
  { "Don't be a slave to formal methods." },
  { 'Organize teams around functionality.' },
  { 'Test early. Test often. Test automatically.' },
  { 'Use saboteurs to test your testing.' },
  { 'Find bugs once.' },
  { 'Sign your work.' },
  { 'Think twice, code once.' },
  { 'No matter how far down the wrong road you have gone, turn back now.' },
  {
    'Why do we never have time to do it right, but always have time to do it over?',
  },
  { 'Weeks of programming can save you hours of planning.' },
  {
    'To iterate is human, to recurse divine.',
    'L. Peter Deutsch',
  },
  {
    'Computers are useless. They can only give you answers.',
    'Pablo Picasso',
  },
  {
    'The question of whether computers can think is like the question of whether submarines can swim.',
    'Edsger W. Dijkstra',
  },
  {
    "It's ridiculous to live 100 years and only be able to remember 30 million bytes. You know, less than a compact disc. The human condition is really becoming more obsolete every minute.",
    'Marvin Minsky',
  },
  {
    "The city's central computer told you? R2D2, you know better than to trust a strange computer!",
    'C3PO',
  },
  {
    'Most software today is very much like an Egyptian pyramid with millions of bricks piled on top of each other, with no structural integrity, but just done by brute force and thousands of slaves.',
    'Alan Kay',
  },
  {
    'I\'ve finally learned what "upward compatible" means. It means we get to keep all our old mistakes.',
    'Dennie van Tassel',
  },
  {
    "There are two major products that come out of Berkeley: LSD and UNIX. We don't believe this to be a coincidence.",
    'Jeremy S. Anderson',
  },
  {
    "The bulk of all patents are crap. Spending time reading them is stupid. It's up to the patent owner to do so, and to enforce them.",
    'Linus Torvalds',
  },
  {
    'Controlling complexity is the essence of computer programming.',
    'Brian Kernighan',
  },
  {
    'Complexity kills. It sucks the life out of developers, it makes products difficult to plan, build and test, it introduces security challenges, and it causes end-user and administrator frustration.',
    'Ray Ozzie',
  },
  {
    'The function of good software is to make the complex appear to be simple.',
    'Grady Booch',
  },
  {
    "There's an old story about the person who wished his computer were as easy to use as his telephone. That wish has come true, since I no longer know how to use my telephone.",
    'Bjarne Stroustrup',
  },
  {
    'There are only two industries that refer to their customers as "users".',
    'Edward Tufte',
  },
  {
    'Most of you are familiar with the virtues of a programmer. There are three, of course: laziness, impatience, and hubris.',
    'Larry Wall',
  },
  {
    'Computer science education cannot make anybody an expert programmer any more than studying brushes and pigment can make somebody an expert painter.',
    'Eric S. Raymond',
  },
  {
    'Optimism is an occupational hazard of programming; feedback is the treatment.',
    'Kent Beck',
  },
  {
    'First, solve the problem. Then, write the code.',
    'John Johnson',
  },
  {
    'Measuring programming progress by lines of code is like measuring aircraft building progress by weight.',
    'Bill Gates',
  },
  {
    "Don't worry if it doesn't work right. If everything did, you'd be out of a job.",
    "Mosher's Law of Software Engineering",
  },
  {
    'A LISP programmer knows the value of everything, but the cost of nothing.',
    'Alan J. Perlis',
  },
  {
    'All problems in computer science can be solved with another level of indirection.',
    'David Wheeler',
  },
  {
    'Functions delay binding; data structures induce binding. Moral: Structure data late in the programming process.',
    'Alan J. Perlis',
  },
  {
    'Easy things should be easy and hard things should be possible.',
    'Larry Wall',
  },
  { 'Nothing is more permanent than a temporary solution.' },
  {
    "If you can't explain something to a six-year-old, you really don't understand it yourself.",
    'Albert Einstein',
  },
  {
    'All programming is an exercise in caching.',
    'Terje Mathisen',
  },
  {
    'Software is hard.',
    'Donald Knuth',
  },
  {
    'They did not know it was impossible, so they did it!',
    'Mark Twain',
  },
  {
    'The object-oriented model makes it easy to build up programs by accretion. What this often means, in practice, is that it provides a structured way to write spaghetti code.',
    'Paul Graham',
  },
  {
    'Question: How does a large software project get to be one year late? Answer: One day at a time!',
  },
  {
    'The first 90% of the code accounts for the first 90% of the development time. The remaining 10% of the code accounts for the other 90% of the development time.',
    'Tom Cargill',
  },
  {
    "In software, we rarely have meaningful requirements. Even if we do, the only measure of success that matters is whether our solution solves the customer's shifting idea of what their problem is.",
    'Jeff Atwood',
  },
  {
    'If debugging is the process of removing bugs, then programming must be the process of putting them in.',
    'Edsger W. Dijkstra',
  },
  {
    '640K ought to be enough for anybody.',
    'Bill Gates, 1981',
  },
  {
    'To understand recursion, one must first understand recursion.',
    'Stephen Hawking',
  },
  {
    'Developing tolerance for imperfection is the key factor in turning chronic starters into consistent finishers.',
    'Jon Acuff',
  },
  {
    'Every great developer you know got there by solving problems they were unqualified to solve until they actually did it.',
    'Patrick McKenzie',
  },
  {
    "The average user doesn't give a damn what happens, as long as (1) it works and (2) it's fast.",
    'Daniel J. Bernstein',
  },
  {
    'Walking on water and developing software from a specification are easy if both are frozen.',
    'Edward V. Berard',
  },
  {
    'Be curious. Read widely. Try new things. I think a lot of what people call intelligence boils down to curiosity.',
    'Aaron Swartz',
  },
  {
    'What one programmer can do in one month, two programmers can do in two months.',
    'Frederick P. Brooks',
  },
}

local function wrap_text(text, max_width)
  local lines = {}
  local words = {}
  for word in text:gmatch('%S+') do
    table.insert(words, word)
  end

  local current_line = ''
  for _, word in ipairs(words) do
    if #current_line == 0 then
      current_line = word
    elseif #current_line + 1 + #word <= max_width then
      current_line = current_line .. ' ' .. word
    else
      table.insert(lines, current_line)
      current_line = word
    end
  end
  if #current_line > 0 then
    table.insert(lines, current_line)
  end

  return lines
end

function M.get()
  math.randomseed(os.time())

  local v = vim.version()
  local quote_entry = M.quotes[math.random(#M.quotes)]
  local quote = quote_entry[1]
  local author = quote_entry[2]

  local max_width = 76
  local quote_lines = wrap_text(quote, max_width)

  -- Find the longest line for border width
  local max_line_length = 0
  for _, line in ipairs(quote_lines) do
    if #line > max_line_length then
      max_line_length = #line
    end
  end

  -- Add author line if present
  local author_line = ''
  if author then
    author_line = '- ' .. author
    if #author_line > max_line_length then
      max_line_length = #author_line
    end
  end

  local cow = {
    '',
    ' ' .. string.rep('_', max_line_length + 2),
  }

  -- Add quote lines
  for _, line in ipairs(quote_lines) do
    table.insert(
      cow,
      '< ' .. line .. string.rep(' ', max_line_length - #line) .. ' >'
    )
  end

  -- Add author line if present
  if author then
    table.insert(cow, '<' .. string.rep(' ', max_line_length + 2) .. '>')
    table.insert(
      cow,
      '< '
        .. author_line
        .. string.rep(' ', max_line_length - #author_line)
        .. ' >'
    )
  end

  table.insert(cow, ' ' .. string.rep('-', max_line_length + 2))
  table.insert(cow, '     \\   ^__^       ')
  table.insert(cow, '       \\  (oo)\\_______')
  table.insert(cow, '              (__)\\       )\\/\\')
  table.insert(cow, '                ||----w |')
  table.insert(cow, '                ||     ||')
  table.insert(cow, '')
  table.insert(cow, '')
  table.insert(cow, '')
  table.insert(cow, '         ' .. v.major .. '.' .. v.minor .. '.' .. v.patch)

  return cow
end

return M
