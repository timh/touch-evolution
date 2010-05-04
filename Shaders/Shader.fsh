//
//  Shader.fsh
//  Evo1
//
//  Created by Tim Hinderliter on 4/25/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
