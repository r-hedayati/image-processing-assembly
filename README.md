# image-processing-assembly

This repository contains assembly language source code and resources for various image processing effects and algorithms. The project demonstrates how to manipulate bitmap images using x86 assembly, including grayscale conversion, edge detection, mirroring, rotation, and more.

## Project Structure

-   `Main Code/` — Contains subfolders for each image processing effect, with corresponding assembly source files and compiled kernels.
-   `Library/` — Includes assembly include files, bootloader code, and configuration files used by the main code.
-   `Document/` — Sample images and documentation resources.
-   `LICENSE` — License information for the project.

## How to Use

1.  **Requirements:**
    -   x86 assembler (e.g., NASM)
    -   Emulator or real hardware capable of running 16-bit code (e.g., QEMU, Bochs)
2.  **Build:**
    -   Assemble the `.asm` files in `Main Code/*/` using NASM or your preferred assembler.
    -   Use the provided bootloader and include files from `Library/` as needed.
3.  **Run:**
    -   Load the compiled kernel files on a floppy image or emulator.
    -   Use the sample images in `Document/` for testing.

## Image Processing Effects

-   **Binary1, Binary2:** Binary thresholding
-   **Black & White:** Black and white conversion
-   **Blue Effect:** Blue color filter
-   **Chesboard:** Chessboard effect
-   **Edge:** Edge detection
-   **Focus Detection:** Focus/blur detection
-   **Main Picture:** Main image display
-   **Mirror:** Mirror effect
-   **Negative:** Negative image effect
-   **Rotate:** Image rotation
-   **Striped:** Striped pattern effect
-   **Two Level:** Two-level thresholding

## Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements or new features.

## License

See `LICENSE` for details.