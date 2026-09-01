const PET_FRAME_ID = "codex-web-pet-overlay";
const PET_FRAME_MARKER = "codexWebPet";
const PET_FRAME_MESSAGE = "codex-web-pet-frame-message";

type PetOverlayStateListener = (isOpen: boolean) => void;

let notifyState: PetOverlayStateListener = () => undefined;

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function isPetFrame(): boolean {
  return (
    new URLSearchParams(window.location.search).get(PET_FRAME_MARKER) === "1"
  );
}

function getPetFrame(): HTMLIFrameElement | null {
  return document.getElementById(PET_FRAME_ID) as HTMLIFrameElement | null;
}

function sendFrameMessage(action: "close" | "open"): void {
  if (window.parent === window) {
    return;
  }
  window.parent.postMessage(
    { type: PET_FRAME_MESSAGE, action },
    window.location.origin,
  );
}

function openPetFrame(): void {
  if (isPetFrame()) {
    sendFrameMessage("open");
    notifyState(true);
    return;
  }

  if (getPetFrame()) {
    notifyState(true);
    return;
  }

  const iframe = document.createElement("iframe");
  iframe.id = PET_FRAME_ID;
  iframe.title = "Codex Pet";
  iframe.src = `/?${new URLSearchParams({
    initialRoute: "/avatar-overlay",
    [PET_FRAME_MARKER]: "1",
  }).toString()}`;
  Object.assign(iframe.style, {
    background: "transparent",
    border: "0",
    bottom: "16px",
    colorScheme: "normal",
    height: "320px",
    overflow: "hidden",
    position: "fixed",
    right: "16px",
    width: "356px",
    zIndex: "2147483646",
  });
  document.body.appendChild(iframe);
  notifyState(true);
}

function closePetFrame(): void {
  if (isPetFrame()) {
    sendFrameMessage("close");
    notifyState(false);
    return;
  }

  getPetFrame()?.remove();
  notifyState(false);
}

export function installWebPetOverlay(listener: PetOverlayStateListener): void {
  notifyState = listener;

  if (isPetFrame()) {
    document.documentElement.style.background = "transparent";
    window.addEventListener("DOMContentLoaded", () => {
      document.body.style.background = "transparent";
      document.body.style.overflow = "hidden";
    });
    return;
  }

  window.addEventListener("message", (event) => {
    if (event.origin !== window.location.origin || !isRecord(event.data)) {
      return;
    }
    if (event.data.type !== PET_FRAME_MESSAGE) {
      return;
    }
    if (event.data.action === "close") {
      closePetFrame();
    } else if (event.data.action === "open") {
      openPetFrame();
    }
  });
}

export function handleWebPetOverlayMessage(value: unknown): boolean {
  if (!isRecord(value) || typeof value.type !== "string") {
    return false;
  }

  switch (value.type) {
    case "avatar-overlay-open":
      openPetFrame();
      return true;
    case "avatar-overlay-close":
    case "avatar-overlay-hide":
      closePetFrame();
      return true;
    case "avatar-overlay-open-state-request":
      notifyState(isPetFrame() || getPetFrame() !== null);
      return true;
    default:
      return isPetFrame() && value.type.startsWith("avatar-overlay-");
  }
}
