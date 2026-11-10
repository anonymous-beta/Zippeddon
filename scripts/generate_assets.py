
from pathlib import Path
from PIL import Image, ImageEnhance, ImageFilter
import sys

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "assets" / "source" / "zippeddon_logo.png"
ASSETS = ROOT / "assets"

OUTPUTS = {
    "branding": ASSETS / "branding",
    "icons": ASSETS / "icons",
    "splash": ASSETS / "splash",
    "backgrounds": ASSETS / "backgrounds",
}

BACKGROUND = (12, 19, 27)


def prepare_directories():
    for directory in OUTPUTS.values():
        directory.mkdir(parents=True, exist_ok=True)


def load_source():
    if not SOURCE.exists():
        raise FileNotFoundError(
            f"Logo not found: {SOURCE}\n"
            "Upload the original logo to assets/source/zippeddon_logo.png"
        )

    image = Image.open(SOURCE).convert("RGB")

    if image.width < 128 or image.height < 128:
        raise ValueError("The supplied logo image is too small.")

    return image


def fit_square(image, size, margin=0.88):
    canvas = Image.new("RGB", (size, size), BACKGROUND)

    image = image.copy()
    image.thumbnail(
        (int(size * margin), int(size * margin)),
        Image.Resampling.LANCZOS,
    )

    x = (size - image.width) // 2
    y = (size - image.height) // 2

    canvas.paste(image, (x, y))
    return canvas


def create_icons(image):
    icon_dir = OUTPUTS["icons"]

    fit_square(image, 1024).save(
        icon_dir / "app_icon.png",
        optimize=True,
    )

    fit_square(image, 1024).save(
        icon_dir / "app_icon_foreground.png",
        optimize=True,
    )

    fit_square(image, 512).save(
        icon_dir / "app_icon_512.png",
        optimize=True,
    )

    fit_square(image, 192).save(
        icon_dir / "app_icon_192.png",
        optimize=True,
    )

    fit_square(image, 180).save(
        icon_dir / "ios_app_icon.png",
        optimize=True,
    )


def create_splash(image):
    canvas = Image.new("RGB", (1600, 1600), BACKGROUND)

    logo = image.copy()
    logo.thumbnail((1280, 1280), Image.Resampling.LANCZOS)

    x = (1600 - logo.width) // 2
    y = (1600 - logo.height) // 2

    canvas.paste(logo, (x, y))

    canvas.save(
        OUTPUTS["splash"] / "splash_logo.png",
        optimize=True,
    )


def create_background(image):
    width, height = 1600, 1000

    scale = max(
        width / image.width,
        height / image.height,
    )

    resized = image.resize(
        (
            int(image.width * scale),
            int(image.height * scale),
        ),
        Image.Resampling.LANCZOS,
    )

    left = (resized.width - width) // 2
    top = (resized.height - height) // 2

    background = resized.crop(
        (left, top, left + width, top + height)
    )

    background = ImageEnhance.Brightness(
        background
    ).enhance(0.38)

    background = ImageEnhance.Color(
        background
    ).enhance(0.75)

    background = background.filter(
        ImageFilter.GaussianBlur(radius=3)
    )

    dark_layer = Image.new(
        "RGB",
        (width, height),
        (8, 14, 20),
    )

    background = Image.blend(
        dark_layer,
        background,
        0.72,
    )

    background.save(
        OUTPUTS["backgrounds"] / "godzilla_background.png",
        optimize=True,
    )


def main():
    print("ZIPPEDDON ASSET GENERATOR")
    print("------------------------")

    prepare_directories()
    image = load_source()

    image.save(
        OUTPUTS["branding"] / "zippeddon_logo.png",
        optimize=True,
    )

    create_icons(image)
    create_splash(image)
    create_background(image)

    print("Asset generation completed.")

    for directory in OUTPUTS.values():
        for file in sorted(directory.glob("*.png")):
            print(f"Created: {file.relative_to(ROOT)}")


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(f"ASSET GENERATION FAILED: {error}")
        sys.exit(1)
