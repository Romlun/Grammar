#if os(iOS)
import SwiftUI

@main
struct WriteProiOS: App {
    var body: some Scene {
        WindowGroup {
            ContentViewiOS()
                .background(Color(.systemBackground).ignoresSafeArea(.all))
        }
    }
}
#endif
