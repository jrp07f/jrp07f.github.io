import { EngProdAccountType, EngDevAccountType, EngProdAccount, EngDevAccount } from '@ginger.io/cdk-constructs'
import { Stage, StageProps } from 'aws-cdk-lib'
import { Construct } from 'constructs'
import { FlutterWebStack } from './FlutterWebStack'

export class FlutterWebStage extends Stage {
  constructor(scope: Construct, id: string, props: StageProps) {
    super(scope, id, props)
    const account = this.getAccount()

    new FlutterWebStack(this, {
      account,
      flutterVersion: '3.7.12'
    })
  }

  private getAccount(): EngProdAccountType | EngDevAccountType {
    const account = [EngProdAccount, EngDevAccount].find((account) => account.id === this.account)
    if (account) {
      return account
    } else {
      throw new Error(
        `Expected this Stage to be deployed either to the EngProd or EngDev account, but got another account instead, with id: ${this.account}`
      )
    }
  }
}
