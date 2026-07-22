package pack; 
    import ALU_pkg::*;
   // Note : you should include in an ascending order to preserve compilation dependency 
   
    // Define DEBUG macro for debug messages throughout the verification environment
    // `define DEBUG
   
    // Base class (must be first - all other classes extend from this)
    `include "class_base.svh"
    
    // Transaction class (used by all verification components)
    `include "class_based_transaction.svh"
    
    // Verification components (extend base class, use transaction)
    `include "class_based_generator.svh"
    `include "class_based_driver.svh"
    `include "class_based_scoreboard.svh"
    `include "class_based_subscriber.svh"
    `include "class_based_monitor.svh"  // Monitor uses scoreboard & subscriber, so must come after them
    
    // Environment class (uses all components above)
    `include "class_based_env.svh"
    `include "class_based_test.svh"
    
endpackage