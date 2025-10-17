import SwiftUI

struct AppLogo: View {
    let size: CGFloat
    let showText: Bool
    
    init(size: CGFloat = 40, showText: Bool = false) {
        self.size = size
        self.showText = showText
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
            
            if showText {
                Text("nano.banana")
                    .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
    }
}

struct AppLogo_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AppLogo(size: 30)
            AppLogo(size: 50, showText: true)
            AppLogo(size: 80, showText: true)
        }
        .padding()
    }
}
