import re
def htmlify(text):
  text = text.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('\'', '&apos;').replace('"', '&quot;')
  return re.sub(r'#(\S+)(\s|$)', '<a class="hashtag" href="hashtag/\\1">#\\1</a>\\2', text)

def f(m):
  m = m.group(1)
  return "'"+htmlify(m)+"'"

out = 'TRUNCATE TABLE `tweets`;\n'
for data in open('seed_isuwitter.sql', 'r').read().splitlines()[39:39+8]:
  #data = data[:100]
  data = re.sub(r"'([^']*)'", f, data)
  out += data + '\n'

open('tweets_modified.sql', 'w').write(out)
