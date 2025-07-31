package matty.lambda.greetings.boundary;

import static java.lang.System.Logger.Level.INFO;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

import org.eclipse.microprofile.config.inject.ConfigProperty;

@ApplicationScoped
public class Greeter {

    static System.Logger LOG = System.getLogger(Greeter.class.getName()); 

    @Inject
    @ConfigProperty(defaultValue = "hello, quarkus on AWS n tha", name="message")
    String message;
    
    public String greetings() {
        LOG.log(INFO, "returning: " + this.message);
        return this.message;
    }

    public void greetings(String userMessage) {
        LOG.log(INFO, "received: " + userMessage);
    }
}
