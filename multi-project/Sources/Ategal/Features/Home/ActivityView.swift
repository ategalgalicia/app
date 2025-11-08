//
//  Created by Michele Restuccia on 5/11/25.
//

import SwiftUI
import AtegalCore

struct ActivityView: View {
    
    @Bindable
    var dataSource: HomeDataSource
    
    private var activity: Activity {
        dataSource.activitySelected!
    }
    
    var body: some View {
        ScrollView {
            contentView
        }
        .actionView {
            actionView
        }
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(activity.title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(activity.description)
                .font(.subheadline)
            
            Text(activity.schedule)
                .font(.subheadline)
            
            Text(activity.address)
                .font(.subheadline)
            
            HStack {
                ForEach(activity.phone, id: \.self) { item in
                    Button {
                        print(1)
                    } label: {
                        Text(item)
                    }
                }
            }
            .font(.subheadline)
        }
        .padding(16)
    }
    
    @ViewBuilder
    private var actionView: some View {
        Button(
            action: {
                print(1)
            }, label: {
                if let email = activity.email {
                    Text(email)
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
        )
        .buttonStyle(.borderedProminent)
        .frame(maxWidth: .infinity, minHeight: 48)
    }
}
