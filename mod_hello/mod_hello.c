#include <httpd.h>
#include <http_protocol.h>
#include <http_config.h>

static int helloworld_handler(request_rec *r)
{
	if (!r->handler || strcmp(r->handler, "helloworld-handler"))
	{
		return DECLINED;
	}

	ap_set_content_type(r, "text/html");
	ap_rprintf(r, "Hello, world!");

	return OK;
}

static void register_hooks(apr_pool_t *pool)
{
	ap_hook_handler(helloworld_handler, NULL, NULL, APR_HOOK_LAST);
}

module AP_MODULE_DECLARE_DATA helloworld_module =
{
	STANDARD20_MODULE_STUFF,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	register_hooks
};
