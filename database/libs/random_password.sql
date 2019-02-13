create or replace function aula.random_password(size int default 6, with_dict boolean default 'f')
   returns text
   language plpython3u
as $$

import string
import random

def create_random_password(with_dict = False):
    def random_without_dict(size = size, with_upper = False):
        chars = string.ascii_lowercase + string.digits
        if with_upper:
          chars += string.ascii_uppercase
        return  ''.join(random.choice(chars) for _ in range(size))

    if with_dict:
      try:
          dict_location = '/usr/share/dict/words'
          with open(dict_location) as f:
              words = f.readlines()
          return ".".join([random.choice(words).strip() for _ in range(2)])
      except FileNotFoundError:
          plpy.warning("""Place a dictionary file in {} to enable
              word-based temp passwords""".format(dict_location))
          return random_without_dict()
    else:
      return random_without_dict()

return create_random_password(with_dict)

$$;

grant execute on function aula.random_password(int, boolean) to aula_authenticator;
