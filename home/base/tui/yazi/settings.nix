{pkgs}: {
  mgr = {
    ratio = [2 4 3];
    sort-by = "alphabetical";
    sort-sensitive = false;
    sort-reverse = false;
    sort-dir-first = true;
    sort-translit = false;
    linemode = "none";
    show_hidden = true;
    show-symlink = true;
    scrolloff = 5;
    mouse-events = ["click" "scroll"];
    title-format = "Yazi: {cwd}";
  };

  preview = {
    wrap = "no";
    tab-size = 2;
    max-width = 1200;
    max-height = 1000;
    cache-dir = "";
    image-delay = 30;
    image-filter = "triangle";
    image-quality = 75;
    ueberzug-scale = 1;
    ueberzug-offset = [0 0 0 0];
  };

  opener = {
    edit = [
      {
        run = "${pkgs.neovim}/bin/nvim %s";
        desc = "nvim";
        for = "unix";
        block = true;
      }
      {
        run = "code %s";
        desc = "code";
        for = "windows";
        orphan = true;
      }
      {
        run = "code -w %s";
        desc = "code (block)";
        for = "windows";
        block = true;
      }
    ];

    play = [
      {
        run = "xdg-open %s1";
        desc = "Play";
        for = "linux";
        orphan = true;
      }
      {
        run = "open %s";
        desc = "Play";
        for = "macos";
      }
      {
        run = "start \"\" %s1";
        desc = "Play";
        for = "windows";
        orphan = true;
      }
      {
        run = "termux-open %s1";
        desc = "Play";
        for = "android";
      }
      {
        run = "mediainfo %s1; echo 'Press enter to exit'; read _";
        block = true;
        desc = "Show media info";
        for = "unix";
      }
      {
        run = "mediainfo %s1 & pause";
        block = true;
        desc = "Show media info";
        for = "windows";
      }
    ];

    open = [
      {
        run = "xdg-open %s1";
        desc = "Open";
        for = "linux";
      }
      {
        run = "open %s";
        desc = "Open";
        for = "macos";
      }
      {
        run = "start \"\" %s1";
        desc = "Open";
        for = "windows";
        orphan = true;
      }
      {
        run = "termux-open %s1";
        desc = "Open";
        for = "android";
      }
    ];

    reveal = [
      {
        run = "xdg-open %d1";
        desc = "Reveal";
        for = "linux";
      }
      {
        run = "open -R %s1";
        desc = "Reveal";
        for = "macos";
      }
      {
        run = "explorer /select,%s1";
        desc = "Reveal";
        for = "windows";
        orphan = true;
      }
      {
        run = "termux-open %d1";
        desc = "Reveal";
        for = "android";
      }
      {
        run = "clear; exiftool %s1; echo 'Press enter to exit'; read _";
        desc = "Show EXIF";
        for = "unix";
        block = true;
      }
    ];

    extract = [
      {
        run = "ya pub extract --list %s";
        desc = "Extract here";
      }
    ];

    download = [
      {
        run = "ya emit download --open %S";
        desc = "Download and open";
      }
      {
        run = "ya emit download %S";
        desc = "Download";
      }
    ];
  };

  open = {
    rules = [
      {
        url = "*/";
        use = ["edit" "open" "reveal"];
      }
      {
        mime = "text/*";
        use = ["edit" "reveal"];
      }
      {
        mime = "image/*";
        use = ["open" "reveal"];
      }
      {
        mime = "{audio,video}/*";
        use = ["play" "reveal"];
      }
      {
        mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
        use = ["extract" "reveal"];
      }
      {
        mime = "application/{json,ndjson}";
        use = ["edit" "reveal"];
      }
      {
        mime = "*/javascript";
        use = ["edit" "reveal"];
      }
      {
        mime = "inode/empty";
        use = ["edit" "reveal"];
      }
      {
        mime = "vfs/{absent,stale}";
        use = "download";
      }
      {
        url = "*";
        use = ["open" "reveal"];
      }
    ];
  };

  tasks = {
    micro-workers = 10;
    macro-workers = 10;
    bizarre-retry = 3;
    image-alloc = 536870912;
    image-bound = [10000 10000];
    suppress-preload = false;
  };

  plugin = {
    fetchers = [
      {
        id = "mime";
        url = "*/";
        run = "mime.dir";
        group = "folder";
        prio = "high";
      }
      {
        id = "mime";
        url = "local://*";
        run = "mime.local";
        group = "local";
        prio = "high";
      }
      {
        id = "mime";
        url = "remote://*";
        run = "mime.remote";
        group = "remote";
        prio = "high";
      }
    ];

    spotters = [
      {
        url = "*/";
        run = "folder";
      }
      {
        mime = "text/*";
        run = "code";
      }
      {
        mime = "application/{mbox,javascript,wine-extension-ini}";
        run = "code";
      }
      {
        mime = "image/{avif,hei?,jxl}";
        run = "magick";
      }
      {
        mime = "image/svg+xml";
        run = "svg";
      }
      {
        mime = "image/*";
        run = "image";
      }
      {
        mime = "video/*";
        run = "video";
      }
      {
        mime = "vfs/*";
        run = "vfs";
      }
      {
        mime = "null/*";
        run = "null";
      }
      {
        url = "*";
        run = "file";
      }
    ];

    preloaders = [
      {
        mime = "image/{avif,hei?,jxl}";
        run = "magick";
      }
      {
        mime = "image/svg+xml";
        run = "svg";
      }
      {
        mime = "image/*";
        run = "image";
      }
      {
        mime = "video/*";
        run = "video";
      }
      {
        mime = "application/pdf";
        run = "pdf";
      }
      {
        mime = "font/*";
        run = "font";
      }
      {
        mime = "application/ms-opentype";
        run = "font";
      }
    ];

    previewers = [
      {
        url = "*/";
        run = ''piper -- ${pkgs.eza}/bin/eza -TL=3 --color=always --icons=always --group-directories-first --no-quotes "$1"'';
      }
      {
        mime = "text/*";
        run = "code";
      }
      {
        mime = "application/{mbox,javascript,wine-extension-ini}";
        run = "code";
      }
      {
        mime = "application/{json,ndjson}";
        run = "json";
      }
      {
        mime = "image/{avif,hei?,jxl}";
        run = "magick";
      }
      {
        mime = "image/svg+xml";
        run = "svg";
      }
      {
        mime = "image/*";
        run = "image";
      }
      {
        mime = "video/*";
        run = "video";
      }
      {
        mime = "application/pdf";
        run = "pdf";
      }
      {
        mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
        run = "archive";
      }
      {
        mime = "application/{debian*-package,redhat-package-manager,rpm,android.package-archive}";
        run = "archive";
      }
      {
        url = "*.{AppImage,appimage}";
        run = "archive";
      }
      {
        mime = "application/{iso9660-image,qemu-disk,ms-wim,apple-diskimage}";
        run = "archive";
      }
      {
        mime = "application/virtualbox-{vhd,vhdx}";
        run = "archive";
      }
      {
        url = "*.{img,fat,ext,ext2,ext3,ext4,squashfs,ntfs,hfs,hfsx}";
        run = "archive";
      }
      {
        mime = "font/*";
        run = "font";
      }
      {
        mime = "application/ms-opentype";
        run = "font";
      }
      {
        mime = "inode/empty";
        run = "empty";
      }
      {
        mime = "vfs/*";
        run = "vfs";
      }
      {
        mime = "null/*";
        run = "null";
      }
      {
        url = "*";
        run = "file";
      }
    ];
  };

  input = {
    cursor-blink = false;
    cd-title = "Change directory:";
    cd-origin = "top-center";
    cd-offset = [0 2 50 3];
    create-title = ["Create:" "Create (dir):"];
    create-origin = "top-center";
    create-offset = [0 2 50 3];
    rename-title = "Rename:";
    rename-origin = "hovered";
    rename-offset = [0 1 50 3];
    filter-title = "Filter:";
    filter-origin = "top-center";
    filter-offset = [0 2 50 3];
    find-title = ["Find next:" "Find previous:"];
    find-origin = "top-center";
    find-offset = [0 2 50 3];
    search-title = "Search via {n}:";
    search-origin = "top-center";
    search-offset = [0 2 50 3];
    shell-title = ["Shell:" "Shell (block):"];
    shell-origin = "top-center";
    shell-offset = [0 2 50 3];
  };

  confirm = {
    trash-title = "Trash {n} selected file{s}?";
    trash-origin = "center";
    trash-offset = [0 0 70 20];
    delete-title = "Permanently delete {n} selected file{s}?";
    delete-origin = "center";
    delete-offset = [0 0 70 20];
    overwrite-title = "Overwrite file?";
    overwrite-body = "Will overwrite the following file:";
    overwrite-origin = "center";
    overwrite-offset = [0 0 50 15];
    quit-title = "Quit?";
    quit-body = "There are unfinished tasks, quit anyway?\n(Open task manager with default key 'w')";
    quit-origin = "center";
    quit-offset = [0 0 50 15];
  };

  pick = {
    open-title = "Open with:";
    open-origin = "hovered";
    open-offset = [0 1 50 7];
  };

  which = {
    sort-by = "none";
    sort-sensitive = false;
    sort-reverse = false;
    sort-translit = false;
  };
}
