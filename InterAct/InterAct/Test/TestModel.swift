
import SwiftUI

struct TestView: View {
    var activityID: String
    
    var body: some View {
        VStack {
            // 显示活动列表
            Button(action: {
 
                if let url = URL(string: "XInterActApp://activity?id=\(activityID)") {
                    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                        if success{
                            print(123123123)
                        }
                    })
                }
            }) {
                Text("点击查看活\(activityID)动详情")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}
