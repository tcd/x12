# Installing libxml2 on MacOS

After `brew install libxml2`:

```
If you need to have libxml2 first in your PATH run:
  echo 'export PATH="/usr/local/opt/libxml2/bin:$PATH"' >> ~/.zshrc

For compilers to find libxml2 you may need to set:
  export LDFLAGS="-L/usr/local/opt/libxml2/lib"
  export CPPFLAGS="-I/usr/local/opt/libxml2/include"

For pkg-config to find libxml2 you may need to set:
  export PKG_CONFIG_PATH="/usr/local/opt/libxml2/lib/pkgconfig"
```