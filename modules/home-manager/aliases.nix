_: {
  home.shellAliases = {
    g = "git";
    ga = "git add";
    gaa = "git add --all";
    gc = "git commit --verbose";
    gca = "git commit --verbose --amend";
    glg = "git log --oneline --decorate --graph";
    gld = "git log -p --ext-diff";
    gls = "git status --short -b";
    gst = "git status --long";
    gwat = "git log --raw --no-merges";

    cc = "claude";

    tree = "eza -T";

    #... Pinned by digest (the :latest image already pulled locally). Bump it on purpose.
    excalidraw = "docker run -d --rm --name excalidraw-canvas -p 127.0.0.1:3000:3000 ghcr.io/yctimlin/mcp_excalidraw-canvas@sha256:090c0dd7dbef4613e36dbd12936234661696f4256dce15c0d0692e5ce7b0ff0e";
    excalidraw-stop = "docker stop excalidraw-canvas";
  };
}
