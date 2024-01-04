import {
  AWSAccountWithDomain,
  EngDevAccount,
  EngProdAccount,
  StaticWebsite,
  EngDevAccountType,
  EngProdAccountType
} from '@ginger.io/cdk-constructs'
import { Stack } from 'aws-cdk-lib'
import { Construct } from 'constructs'
import { join } from 'path'

export type Account = EngDevAccountType | EngProdAccountType

interface FlutterWebStackProps {
  account: AWSAccountWithDomain

  /**
   * The flutter version we should use to build the application. We use the cirrusci-provided flutter build image, so
   * the version you pass must be an available tag: https://hub.docker.com/r/cirrusci/flutter
   */
  flutterVersion: string
}

interface Config {
  domainName: string
  allowedOrigins: Array<string>
}

const config: Record<Account['name'], Config> = {
  [EngDevAccount.name]: {
    domainName: 'scheduling.dev.listenernow.com',
    allowedOrigins: [
      "localhost:63634",
      "dev.ginger.io",
      "dev.listenernow.com",
      "content-repository.ginger.dev",
      "ginger-content-repository-dev.s3.amazonaws.com",
      "maintenance.ginger.dev",
    ]
  },
  [EngProdAccount.name]: {
    domainName: 'scheduling.www.listenernow.com',
    allowedOrigins: [
      "data.ginger.io",
      "www.listenernow.com",
      "content-repository.ginger.io",
      "ginger-content-repository-prod.s3.amazonaws.com",
      "maintenance.ginger.io",
    ]
  }
}

export class FlutterWebStack extends Stack {
  constructor(scope: Construct, props: FlutterWebStackProps) {
    super(scope, 'FlutterWeb')
    const { account, flutterVersion } = props
    const { domainName, allowedOrigins } = config[account.name]

    const envType = account === EngProdAccount ? 'WEB_PROD' : 'WEB_STAGING'

    new StaticWebsite(this, 'StaticWebsite', {
      domainName,
      securityConfiguration: {
        corsBehavior: allowedOrigins,
        contentSecurityPolicy:
          "default-src 'self' self; script-src 'self' 'unsafe-inline' 'unsafe-eval' www.gstatic.com cdn.amplitude.com app.link www.googletagmanager.com unpkg.com; style-src 'self' 'unsafe-inline' use.fontawesome.com; img-src 'self' data: blob: content-repository.ginger.dev content-repository.ginger.com content-repository.ginger.io dev.listenernow.com www.listenernow.com i.vimeocdn.com; font-src 'self' use.fontawesome.com fonts.gstatic.com; connect-src 'self' firebase.googleapis.com firebaseinstallations.googleapis.com *.braze.com api2.branch.io *.ginger.io *.ginger.dev *.ginger.com api.amplitude.com *.listenernow.com ginger-content-repository-dev.s3.amazonaws.com ginger-content-repository-prod.s3.amazonaws.com www.google-analytics.com ps.pndsn.com unpkg.com i.vimeocdn.com fonts.gstatic.com fonts.googleapis.com *.webhook.logs.insight.rapid7.com api.stripe.com webhook.logentries.com *.headspace.com; media-src 'self' player.vimeo.com *.akamaized.net assets.ctfassets.net; frame-src 'self' player.vimeo.com; frame-ancestors 'none';"
      }
    })
  }
}
