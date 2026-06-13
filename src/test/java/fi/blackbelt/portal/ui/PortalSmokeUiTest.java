package fi.blackbelt.portal.ui;

import com.microsoft.playwright.Browser;
import com.microsoft.playwright.Page;
import com.microsoft.playwright.Playwright;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;

import static com.microsoft.playwright.assertions.PlaywrightAssertions.assertThat;

/**
 * Smoke-level UI test. Runs only with the ui-tests profile:
 *
 *   mvn verify -Pui-tests
 *
 * Requires Playwright browsers (see README, "UI tests"). This test passes on
 * the empty skeleton because it asserts only static content; flow-level UI
 * tests (add an asset, see it listed) are written once the APIs exist.
 */
@Tag("ui")
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class PortalSmokeUiTest {

    @LocalServerPort
    private int port;

    @Test
    void should_showPortalHeader_when_pageOpens() {
        try (Playwright playwright = Playwright.create()) {
            Browser browser = playwright.chromium().launch();
            Page page = browser.newPage();
            page.navigate("http://localhost:" + port + "/");
            assertThat(page.getByTestId("portal-header-title")).isVisible();
        }
    }
}
