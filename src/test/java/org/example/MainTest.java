package org.example;

import org.junit.jupiter.api.Test;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class MainTest {

    @Test
    public void testMainOutput() {
        // Redirect System.out to capture console output
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        PrintStream originalOut = System.out;
        System.setOut(new PrintStream(outContent));

        try {
            // Run the main method
            Main.main(new String[]{});
            
            String output = outContent.toString();

            // Assertions
            assertTrue(output.contains("Hello and welcome!"), "Should contain welcome message");
            assertTrue(output.contains("i = 1"), "Should print first iteration");
            assertTrue(output.contains("i = 5"), "Should print final iteration");
            
        } finally {
            // Restore the original System.out
            System.setOut(originalOut);
        }
    }
}
