.section ".text.boot"  // Make sure the linker puts this at the start of the kernel image

.global _start  // Execution starts here

_start:
    // Copy following into register r0
    ldr r0,=0x20200000
    // Prepare byte for OK LED
    mov r1,#1
    lsl r1,#18
    str r1,[r0,#4]
    // Turn on OK LED
    mov r1,#1
    lsl r1,#16
    str r1,[r0,#40]

    // Check processor ID is zero (executing on main core), else hang
    mrs     x1, mpidr_el1
    and     x1, x1, #3
    cbz     x1, 2f
    // We're not on the main core, so hang in an infinite wait loop
1:  wfe
    b       1b
2:  // We're on the main core!

    // Set stack to start below our code
    ldr     x1, =_start
    mov     sp, x1

    // Clean the BSS section
    ldr     x1, =__bss_start     // Start address
    ldr     w2, =__bss_size      // Size of the section
3:  cbz     w2, 4f               // If zero, exit the loop
    str     xzr, [x1], #8
    sub     w2, w2, #1
    cbnz    w2, 3b               // Loop if non-zero

    // Jump to our main() routine in C, the point of no return
4:  bl      main
    // In case it does return, halt the master core too
    b       1b
